/********************************************************************************* 
  *Author:      Aresnan
  *Version:     1.0
  *Date:        2021.10.12
  *Description: FresnelSurfaceShader
  *Function List: 
**********************************************************************************/
Shader "Custom/FresnelSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _FresnelColor ("FresnelColor", Color) = (1,1,1,1)
        _FresnelRange ("FresnelRange", Range(0,2)) = 1        
        // [optional: attribute]
        // [PowerSlider(4)] _FresnelExponent ("Fresnel Exponent", Range(0.25, 4)) = 1
        _Emission ("Emission", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir;
            INTERNAL_DATA//unity needs it to generate the worldspace normal
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _Emission;
        fixed4 _FresnelColor;
        float _FresnelRange;


        // 使用该功能可以渲染多拷贝的、相同 mesh 和 material 的对象，可以降低drawcall，每个实例可以有不同的参数
        // unity 自动选择MeshRenderer，而不支持SkinnedMeshRenderer
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // 默认只支持Transform，可以添加其他属性
            // UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            /*-------------------------------------------Ares执行代码----------------------------------------------*/
            //添加菲涅尔效果（只与法线方向和光源方向有关）
            // float fresnel = dot(IN.worldNormal, float(.0, 1.0, 0));//固定方向
            float fresnel = dot(IN.worldNormal, IN.viewDir);//跟随视角
            fresnel *= _FresnelRange;
            //使边缘高亮（取反）
            fresnel = saturate(1 - fresnel);
            _FresnelColor *= fresnel;
            o.Emission = _FresnelColor + _Emission;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
