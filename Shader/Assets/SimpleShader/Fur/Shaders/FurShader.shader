/********************************************************************************* 
  *Author:      Aresnan
  *Version:     1.0
  *Date:        2021.9.29
  *Description: 皮毛基础shader
  *Function List: 
**********************************************************************************/
Shader "Custom/FurShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Length ("FurLength", Range(0,0.2)) = 0.1
        _CutAlpha("CutAlpha", Range(0,1)) = 0.5   
        _CutoffEnd("_CutoffEnd", Range(0,1)) = 0.5  
        _EdgeFade("_EdgeFade", Range(0,1)) = 0.5    
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
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

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

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.05
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.10
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.15
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.20
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.25
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.30
        # include "FurBase.cginc"
        ENDCG
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.35
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.40
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.45
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.50
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.55
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.60
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.63
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.65
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.68
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.70
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.73
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.75
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.78
        # include "FurBase.cginc"
        ENDCG

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
        #define FUR_RENDER_Q  0.80
        # include "FurBase.cginc"
        ENDCG
    }
    FallBack "Diffuse"
}
