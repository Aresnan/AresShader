/*************************************************************************************
*Author:      Aresnan
*Version:     1.0
*Date:        2021.10.22
*Description: ClipModelSurfaceShader 判断平面坐标时使用向量的方法还有一点意思
*Function List: 
**************************************************************************************/
Shader "Custom/ClipModelSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Emission ("Emission", color) = (0,0,0)
        _CutoffColor("Cutoff Color", Color) = (1,0,1,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        // 将背面剔除取消
        Cull Off
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        float4 _Plane;
        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float facing : VFACE;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        half3 _Emission;
        float4 _CutoffColor;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            //1代表外部，-1代表内部
            float facing = IN.facing * 0.5 + 0.5;
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb * facing;
            o.Metallic = _Metallic * facing;
            o.Smoothness = _Glossiness * facing;
            o.Alpha = c.a;
            //计算当前点的位置,up > 0， in = 0; bottom < 0;
            /*****************************************方法一*********************************************/
            //计算plane的原点向量
            float3 vec = _Plane.xyz * (-_Plane.w);
            //计算由plane原点出发，当前像素的向量
            float3 newPixelPos = IN.worldPos - vec;
            float distance = dot(newPixelPos, _Plane.xyz);
            /*****************************************方法二*********************************************/
            //根据当前平面的法线方向到原点平面的距离判断分界线位置
            // float distance = dot(IN.worldPos, _Plane.xyz);
            // distance = distance + _Plane.w;
            clip(-distance);// x 小于0则丢弃
            o.Emission = lerp(_CutoffColor, _Emission, facing);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
