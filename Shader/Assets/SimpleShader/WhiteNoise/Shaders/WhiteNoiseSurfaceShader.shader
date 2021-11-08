/*************************************************************************************
*Author:      Aresnan
*Version:     1.0
*Date:        2021.11.08
*Description: WhiteNoiseSurfaceShader 
*Function List: 用当前世界坐标乘以一个随机数，以构造出一个无序的小数位，用以生成对应点色值
**************************************************************************************/
Shader "Custom/WhiteNoiseSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _CellSize ("Cell Size", Vector) = (1,1,1,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0
        #include "WhiteNoise.cginc"

        sampler2D _MainTex;

        struct Input
        {
            float3 worldPos;
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float4 _CellSize;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        float rand(float3 vec)
        {
            //设置成周期函数，防止坐标过大而超出范围
            float3 smallValue = sin(vec);
            float random = dot(smallValue, float3(12.9898, 78.233, 37.719));
            //返回输入值的小数部分
            random = frac(random * 1400.5453);
            return random;
        }

        float randDir(float3 vec, float3 dotDir = float3(12.9898, 78.233, 37.719))
        {
            //设置成周期函数，防止坐标过大而超出范围
            float3 smallValue = sin(vec);
            float random = dot(smallValue, dotDir);
            //返回输入值的小数部分
            random = frac(random * 1400.5453);
            return random;
        }

        //基础noise
        void surf1 (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            /**********************************************************************************************/
            //RGB 三个值相同时，代表灰度
            // o.Albedo = c.rgb * rand(IN.worldPos);

            float3 col = float3(
            randDir(IN.worldPos, float3(12.989, 78.233, 37.719)),
            randDir(IN.worldPos, float3(39.346, 11.135, 83.155)),
            randDir(IN.worldPos, float3(73.156, 52.235, 09.151))
            );
            o.Albedo = c.rgb * col;
        }
        
        //使用函数库
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            /**********************************************************************************************/
            float3 value = floor(IN.worldPos / _CellSize);
            o.Albedo = rand3dTo3d(value);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
