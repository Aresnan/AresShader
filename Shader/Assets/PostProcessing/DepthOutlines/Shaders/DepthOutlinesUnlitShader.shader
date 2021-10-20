/*************************************************************************************
*Author:      Aresnan
*Version:     1.0
*Date:        2021.10.20
*Description: DepthOutlinesUnlitShader 
*Function List: 
**************************************************************************************/
Shader "Unlit/DepthOutlinesUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _NormalMult ("Normal Outline Multiplier", Range(0,4)) = 1
        _DepthMult ("Depth Outline Multiplier", Range(0,4)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _OutlineColor;
            float _NormalMult;
            float _DepthMult;
            sampler2D _CameraDepthNormalsTexture;
            //纹理的像素大小
            float4 _CameraDepthNormalsTexture_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float GetOutline(float depth, float2 uv, float2 offset)
            {
                float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture, uv + _CameraDepthNormalsTexture_TexelSize.xy * offset);
                float3 neighborNormal;
                float neighborDepth;
                DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);
                neighborDepth = neighborDepth * _ProjectionParams.z;
                //计算边缘，深度相差越大越接近1，越近越接近0
                float outline = depth - neighborDepth;
                return outline;
            }

            void GetOutline1(inout float depthOutline, inout float normalOutline, float baseDepth, float3 baseNormal, float2 uv, float2 offset)
            {
                float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture, uv + _CameraDepthNormalsTexture_TexelSize.xy * offset);
                float3 neighborNormal;
                float neighborDepth;
                DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);
                neighborDepth = neighborDepth * _ProjectionParams.z;

                float outline = baseDepth - neighborDepth;
                depthOutline += outline;
                //计算法线outline(法线夹角越大，边缘越明显，所以也可以使用 1 - dot(a,b))
                float3 normalDifference = baseNormal - neighborNormal;
                normalDifference = normalDifference.r + normalDifference.g + normalDifference.b;
                normalOutline = normalOutline + normalDifference;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                //计算深度常规操作
                float4 depthNor = tex2D(_CameraDepthNormalsTexture, i.uv);
                float3 normal;
                float depth;
                DecodeDepthNormal(depthNor, depth, normal);
                depth = depth * _ProjectionParams.z;
                /*****************************************function1*********************************************/
                //计算相邻的像素位置
                float depthOutline = GetOutline(depth, i.uv, float2(0, 1));
                depthOutline += GetOutline(depth, i.uv, float2(0, -1));
                depthOutline += GetOutline(depth, i.uv, float2(1, 0));
                depthOutline += GetOutline(depth, i.uv, float2(-1, 0));
                /***********************************************************************************************/

                /*****************************************function2*********************************************/
                float depthOutline1 = 0;
                float normalOutline = 0;
                GetOutline1(depthOutline1, normalOutline, depth, normal, i.uv, float2(0, 1));
                GetOutline1(depthOutline1, normalOutline, depth, normal, i.uv, float2(0, -1));
                GetOutline1(depthOutline1, normalOutline, depth, normal, i.uv, float2(1, 0));
                GetOutline1(depthOutline1, normalOutline, depth, normal, i.uv, float2(-1, 0));
                /***********************************************************************************************/
                //通过深度和法线两种测试最终决定当前像素是否高亮
                normalOutline = normalOutline * _NormalMult;
                normalOutline = saturate(normalOutline);

                depthOutline1 = depthOutline1 * _DepthMult;
                depthOutline1 = saturate(depthOutline1);

                float outline =  normalOutline + depthOutline1;
                float4 color = lerp(col, _OutlineColor, outline);
                return color;
            }
            ENDCG
        }
    }
}
// Texelsize ：当前纹理的大小
// - x contains 1.0/width
// - y contains 1.0/height
// - z contains width
// - w contains height