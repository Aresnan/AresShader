/********************************************************************************* 
  *Author:      Aresnan
  *Version:     1.0
  *Date:        2021.9.30
  *Description: TriplanarShader
  *Function List: 
**********************************************************************************/
Shader "Unlit/TriplanarShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                //float2 uv : TEXCOORD0;不需要原始uv，通过当前的世界坐标来生成可变uv
                float3 normal : NORMAL;
            };

            struct v2f
            {
                // float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float3 worldPos : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //将顶点转化为世界坐标
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos.xyz;
                //只存储法线的模
                o.normal = abs(v.normal);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //计算动态的三个面的uv
                float2 up_uv = i.worldPos.zx;
                float2 front_uv = i.worldPos.yx;
                float2 left_uv = i.worldPos.yz;
                //注1
                up_uv = TRANSFORM_TEX(up_uv, _MainTex);
                front_uv = TRANSFORM_TEX(front_uv, _MainTex);
                left_uv = TRANSFORM_TEX(left_uv, _MainTex);
                //纹理采样
                fixed4 col0 = tex2D(_MainTex, up_uv);
                fixed4 col1 = tex2D(_MainTex, front_uv);
                fixed4 col2 = tex2D(_MainTex, left_uv);
                //根据法线在该平面的分量来进行color融合
                fixed4 col = col0 * i.normal.y + col1 * i.normal.z + col2 * i.normal.x;
                return col;
            }
            ENDCG
        }
    }
}
// 注1：
// TRANSFORM_TEX 是用来和Tilling,Offset进行运算，确保纹理的缩放和偏移是正确的；
// 如下这两个等式相同
// o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
// o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
// -----------------------------------------------------------
// _MainTex_ST
// x contains X tiling value
// y contains Y tiling value
// z contains X offset value
// w contains Y offset value