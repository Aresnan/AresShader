/*************************************************************************************
*Author:      Aresnan
*Version:     1.0
*Date:        2021.10.29
*Description: BlurUnlitShader 
*Function List: 熟悉高斯分布，并且了解shader变异体逻辑
**************************************************************************************/
Shader "Unlit/BlurUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SAMPLES ("SAMPLES", float) = 10
        _BlurSize("Blur Size", Range(0,0.5)) = 0
        [KeywordEnum(Low, Medium, High)] _BlurCount ("Sample amount", Float) = 0
        [Toggle(GAUSS)] _Gauss ("Gaussian Blur", float) = 0
        _StandardDeviation("Standard Deviation (Gauss only)", Range(0, 0.1)) = 0.02         
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
            //在运行时unity通过keyword选择激活哪一个关键字，如果没有，默认激活第一个
            //注2
            #pragma multi_compile _BLURCOUNT_LOW _BLURCOUNT_MEDIUM _            

            #include "UnityCG.cginc"
            //声明时大小写无所谓，但是在multi_compile 和 定义时要使用全大写
            #if _BLURCOUNT_LOW
                #define _BlurCount 10
            #elif _BLURCOUNT_MEDIUM
                #define _BlurCount 30
            #else
                #define _BlurCount 100
            #endif

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
            float4 _MainTex_TexelSize;

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
                // fixed4 col = tex2D(_MainTex, i.uv);
                float4 col = 0;
                /*****************************************水平blur*********************************************/
                for(int index = 0; index < _BlurCount; index++)
                {
                    //获取正负号
                    float sign = index % 2 == 0? 1: -1;
                    //重构uv坐标
                    float u = i.uv.x + _MainTex_TexelSize.x * index * sign;
                    float v = i.uv.y;                   
                    col += tex2D(_MainTex, float2(u,v));

                    float u1 = i.uv.x;
                    float v1 = i.uv.y + _MainTex_TexelSize.y * index * sign;                   
                    col += tex2D(_MainTex, float2(u1,v1));
                }
                col /= (2 * _BlurCount);
                /**********************************************************************************************/
                return col;
            }
            ENDCG
        }
        //高斯模糊
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            //Unity does not include unused variants of shader_feature shaders in the final build（官方解释）
            //注1
            #pragma shader_feature GAUSS

            #include "UnityCG.cginc"

            #define PI 3.14159265359
            #define E 2.71828182846

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
            float _BlurSize;
            float _SAMPLES;
            float _StandardDeviation;

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
                #if GAUSS
                    //标准差为零时，不进行blur操作
                    if(_StandardDeviation == 0)
                    return tex2D(_MainTex, i.uv);
                #endif
                
                float4 col = 0;
                #if GAUSS
                    float sum = 0;
                #else
                    float sum = _SAMPLES;
                #endif
                
                for(float index = 0; index < _SAMPLES; index++){
                    //获得像素偏移值【index/(_SAMPLES-1)】的取值范围为（0，1），相当于取左右的均值
                    float offset = (index/(_SAMPLES-1) - 0.5) * _BlurSize;
                    float2 uv = i.uv + float2(0, offset);
                    #if !GAUSS
                        //不使用高斯时，直接采样
                        col += tex2D(_MainTex, uv);
                    #else
                        //方差
                        float stDevSquared = _StandardDeviation*_StandardDeviation;
                        //高斯公式
                        float gauss = (1 / sqrt(2*PI*stDevSquared)) * pow(E, -((offset*offset)/(2*stDevSquared)));
                        //将正态分布结果添加到sum
                        sum += gauss;
                        col += tex2D(_MainTex, uv) * gauss;
                    #endif
                }
                //对采样值进行平均
                col = col / sum;
                return col;
            }
            ENDCG
        }
    }
}
//注1
// #pragma multi_compile _ TEST
// #pragma shader_feature TEST
// shader_feature 可以仅使用一个变量就可以通过if else 进行判断，但是在编译时如果该变量没有使用，则无法通过代码实时修改
// multi_compile 必须使用两个变量进行判断，一个时不可以使用if else 判断，不过可以通过 _ 进行默认值判断，以节省变量声明
// 例：
//     #if TEST
//         return 0;
//     #else
//         return col;
// shader_feature 可以直接使用，multi_compile必须添加 _ 变量才可以使用

//注2
//unity 官方文档
//This is used with "#pragma multi_compile" in shaders, to enable or disable parts of shader code. 
//Each name will enable "property name" + underscore + "enum name", [uppercased], shader keyword. 
//Up to 9 names can be provided.