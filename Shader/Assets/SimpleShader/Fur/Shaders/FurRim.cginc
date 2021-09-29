/********************************************************************************* 
  *Author:      Aresnan
  *Version:     1.0
  *Date:        2021.9.29
  *Description: 皮毛添加重力，风向shader
  *Function List: 
**********************************************************************************/
#pragma target 3.0
#include "Lighting.cginc"
#include "UnityCG.cginc"

float _Length;
sampler2D _MainTex;
float4 _Color;
float _CutAlpha;
float _CutoffEnd;
float _EdgeFade;
float4 _RimColor;
float _RimPow;

void vert(inout appdata_full v)
{
    //顶点偏移
    //基础位移，只涉及法线方向和层间距
    v.vertex.xyz += v.normal * _Length * FUR_RENDER_Q; 
    //添加了alpha值，透明区域fur的增长速率变小
    // v.vertex.xyz += v.normal * _Length * FUR_RENDER_Q * v.color.a;
}

struct Input{
    float2 uv_MainTex;
    float3 viewDir;
};

void surf(Input IN, inout SurfaceOutputStandard o)
{
    //常规操作
    float4 c = tex2D(_MainTex, IN.uv_MainTex);
    o.Albedo.rgb = c.rgb;
    //后大于前时，返回1，否则0（控制有毛发的区域）
    // o.Alpha = step(_CutAlpha, c.a);
    o.Alpha = step(lerp(_CutAlpha,_CutoffEnd,FUR_RENDER_Q), c.a);

    //越靠近外层，越透明(越到尾部越细)
    float alpha = 1 - (FUR_RENDER_Q * FUR_RENDER_Q);
    //离视角越远的地方，越透明
    float dotVN = dot(IN.viewDir, o.Normal); 
    alpha +=  dotVN - _EdgeFade;
    //Rim：离视角越远的地方，越明显。因为rim是（0,1）所以指数越大，rim越小，颜色越接近边缘
    float rim = 1 - dotVN;
    float4 rimColor = _RimColor * pow(rim,_RimPow);
    o.Albedo += rimColor;
    o.Alpha *= alpha;
}