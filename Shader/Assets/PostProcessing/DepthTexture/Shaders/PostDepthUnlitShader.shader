/*************************************************************************************
  *Author:      Aresnan
  *Version:     1.0
  *Date:        2021.10.15
  *Description: PostDepthUnlitShader ，重点关注wave区域的计算
  *Function List: 
**************************************************************************************/
Shader "Unlit/PostDepthUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveDistance ("Distance from player", float) = 10
        _WaveTrail ("Length of the trail", Range(0,5)) = 1
        _WaveColor ("Color", Color) = (0,0,0,1)
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
            //系统变量_CameraDepthTexture texture range is [1,0] instead of [0,1]
            sampler2D _CameraDepthTexture;
            float _WaveDistance;
            //wave 的宽度
            float _WaveTrail;
            float4 _WaveColor;

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
                _WaveDistance *= _SinTime.w;
                //深度纹理采样
                float depth = tex2D(_CameraDepthTexture, i.uv).r;                
                //注 1
                depth = Linear01Depth(depth);
                //比率乘以最远轴的长度，得到当前深度的实际长度
                depth = depth * _ProjectionParams.z;
                //获得原始纹理颜色
                fixed4 source = tex2D(_MainTex, i.uv);
                //跳过比远裁剪面还远的部分
                if(depth >= _ProjectionParams.z)
                    return source;
                /*-----------------------------------------------------------------------------*/
                // float wave = step(depth, _WaveDistance);
                //注 2
                // float wave = smoothstep(_WaveDistance - _WaveTrail, _WaveDistance, depth);
                // float wave = smoothstep(_WaveDistance, _WaveDistance - _WaveTrail, depth);
                /*-----------------------------------------------------------------------------*/
                //wave前点，远0近1
                float waveFront = step(depth, _WaveDistance);
                //wave后点，远1近0
                float waveTrail = smoothstep(_WaveDistance - _WaveTrail, _WaveDistance, depth);
                //所以只有交集部分为1
                float wave = waveFront * waveTrail;
                //只有wave以外的区域只用原色
                fixed4 col = lerp(source, _WaveColor, wave);
                return col;
            }
            ENDCG
        }
    }
}
/* 1
unity 内置函数
Linear01Depth(i): given high precision value from depth texture i, 
returns corresponding linear depth in range between 0 and 1
本方法由深度缓冲转化为（0,1）的线性值，而如果摄像机的远裁剪面过远的话，
处于近处的物体深度值将无限接近于0，所以近处的将都是黑色，难以区分。
*/

/* 2
smoothstep(a, b, x)可以用来生成0到1的平滑过渡.
0	x < a < b 或 x > a > b
1	x < b < a 或 x > b > a
所以，a b 对调之后，返回值结果取反
*/