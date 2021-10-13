/********************************************************************************* 
  *Author:      Aresnan
  *Version:     1.0
  *Date:        2021.10.13
  *Description: DeformShader ，关键点在于法线的变化，通过切线空间从新计算得出
  *Function List: 
**********************************************************************************/
Shader "Custom/DeformShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        /*-----------------------------------------------------*/
        _Amplitude ("Amplitude", float) = 2
        _Frequency ("Frequency", float) = 2
        _Speed ("Speed", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        //addshadow：根据定点的变化，生成实时的阴影
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        /*-----------------------------------------------------*/
        float _Amplitude;
        float _Frequency;
        float _Speed;

        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        /*-------------------------------------------Ares执行代码----------------------------------------------*/
        void vert(inout appdata_full o){
            // o.vertex.y += sin(o.vertex.x * _Frequency) * _Amplitude;
            //将defromPos认为是三维坐标轴心
            float4 deformPos = o.vertex;
            float value = sin((o.vertex.x + _Time.y * _Speed) * _Frequency) *_Amplitude;
            //对原顶点进行deform变换
            deformPos.y += value;
            //获得原顶点的 T(tangent) 和 B(bitangent) 轴上的两个点
            float3 newTangent = o.vertex + o.tangent * .01;
            //对 T 上取的点进行变换
            newTangent.y += value;
            //因为原顶点法线、T、B、相互正交，所以求出B
            float3 bitangent = cross(o.normal, o.tangent);
            //对 B 上取的点进行变换
            float3 newBitangent = o.vertex + bitangent * .01;
            newBitangent.y += value;
            //根据变换后的两个点求出新的T、B轴
            float3 deformTangent = newTangent - deformPos;
            float3 deformBitangent = newBitangent - deformPos;
            //根据T、B轴求出新的法线
            float3 deformNormal = cross(deformTangent, deformBitangent);
            o.normal = deformNormal;
            o.vertex = deformPos;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
