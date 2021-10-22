/*************************************************************************************
*Author:      Aresnan
*Version:     1.0
*Date:        2021.10.22
*Description: ClipModelSurfaceShader 牢记渲染中各个步骤的顺序
*Function List: 
**************************************************************************************/
Shader "Custom/StencilBufferMainShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0,255)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Zwrite Off
        //模板缓冲，放到cg外；
        Stencil{
            Ref [_StencilRef]
            Comp equal
        }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
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
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
// 优先判断Rq、远近的顺序，之后再进行模板缓冲判断
// 深度缓存和模板缓存操作顺序如下（假定模板缓存开启）
//      （1）执行模板测试，如果失败，执行模板测试失败的操作并且丢弃此像素（也就是禁止其写入后台缓存或颜色缓存），如果测试通过，执行下一步
//      （2）执行深度测试（或Z测试），如果失败，执行深度测试失败的操作，并且丢弃此像素。如果通过，那么执行模板通过操作并且写入像素到后台缓存中。 
// 深度测试执行仅在模板测试通过或则模板测试关闭的情况下。
