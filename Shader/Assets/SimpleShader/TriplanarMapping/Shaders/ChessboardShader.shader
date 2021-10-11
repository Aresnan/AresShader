/********************************************************************************* 
  *Author:      Aresnan
  *Version:     1.0
  *Date:        2021.10.11
  *Description: ChessboardShader
  *Function List: 
**********************************************************************************/
Shader "Unlit/ChessboardShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale("Scale",float) = 1
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
                // float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldPos : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Scale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                //转换世界坐标
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos.xyz;
                //转换法线
                // float worldNor = UnityObjectToWorldNormal(v.normal);
                // o.normal = (worldNor);
                o.normal = abs(normalize(v.normal));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //计算scale之后的坐标向量
                float3 adjustedWorldPos = floor(i.worldPos * _Scale);
                //注1
                //法线经过归一化之后，各个方向的分量肯定小于1
                float xy = (adjustedWorldPos.x + adjustedWorldPos.y) * round(i.normal.z);
                float xz = (adjustedWorldPos.x + adjustedWorldPos.z) * round(i.normal.y);
                float yz = (adjustedWorldPos.y + adjustedWorldPos.z) * round(i.normal.x);

                //会有噪点(原值为偶或奇，floor之后的值对偶数没影响，对奇数可能改变成偶数,所以不为1的地方都降为0，导致产生噪点)
                // float xy = (adjustedWorldPos.x + adjustedWorldPos.y) * floor(i.normal.z);
                // float xz = (adjustedWorldPos.x + adjustedWorldPos.z) * floor(i.normal.y);
                // float yz = (adjustedWorldPos.y + adjustedWorldPos.z) * floor(i.normal.x);

                //偶数区域会因为乘以了一个（0,1）的值而多出小数值，在纯黑的区域内产生白色噪点
                // float xy = (adjustedWorldPos.x + adjustedWorldPos.y) * (i.normal.z);
                // float xz = (adjustedWorldPos.x + adjustedWorldPos.z) * (i.normal.y);
                // float yz = (adjustedWorldPos.y + adjustedWorldPos.z) * (i.normal.x);

                float chessboard = (xy + xz + yz);
                chessboard = frac(0.5 * chessboard);
                //奇白偶黑
                chessboard *= 2;//结果为0或1
                return chessboard;
            }
            ENDCG
        }
    }
}
// 注：
// floor(a):返回不大于a的整数
// frac(a):返回a的小数部分

// 注1：
//    / \ y
//     |
//     |
//   3 |-------
//     | 2 | 3 |
//   2 |-------
//     | 1 | 2 |
//   1 |-------
//     | 0 | 1 |
//     |---------—————————————————— x
//     0   1   2   3   4
//     形成奇偶交错的棋盘布局


