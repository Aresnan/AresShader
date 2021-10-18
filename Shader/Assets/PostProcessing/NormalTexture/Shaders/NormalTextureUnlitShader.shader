/*************************************************************************************
*Author:      Aresnan
*Version:     1.0
*Date:        2021.10.18
*Description: NormalTextureUnlitShader ，Screen法线根据摄像头确定，
                                        所以需要通过摄像头变换矩阵进行实时变化。
                                        而针对摸一个模型时，只需要进行模型法线计算
*Function List: 
**************************************************************************************/
Shader "Unlit/NormalTextureUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalColor ("NormalColor", Color) = (1,1,1,1)
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
            float4 _NormalColor;
            sampler2D _CameraDepthNormalsTexture;
            float4x4 _Matrix;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 source = tex2D(_MainTex, i.uv);
                //获取法线和深度纹理
                float4 normalDepthTex = tex2D(_CameraDepthNormalsTexture, i.uv);                
                //分别拿到法线和深度(法线是相对摄像机进行存储的)
                float3 normal;
                float depth;
                DecodeDepthNormal(normalDepthTex, depth, normal);
                //实际深度值
                depth = depth * _ProjectionParams.z;
                //控制天空盒
                if(depth >= _ProjectionParams.z)
                return source;
                //将法线转换到世界坐标（只要前三维，第四维的位移省略）
                normal = mul((float3x3)_Matrix, normal);
                float up = dot(float3(0,1,0), normal);
                up = smoothstep(0.5, 0.9, up);
                //融合原有的颜色
                float4 col = lerp(source, _NormalColor, up);
                return col;
            }
            ENDCG
        }
    }
}
