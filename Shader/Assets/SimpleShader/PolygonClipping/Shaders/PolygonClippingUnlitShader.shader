/********************************************************************************* 
  *Author:      Aresnan
  *Version:     1.0
  *Date:        2021.10.12
  *Description: PolygonClippingUnlitShader ，关键点在于计算一个点在直线的左右侧，通过法线和一点到直线的向量点乘的正负来判断
                                             也可以通过叉积判断位置
  *Function List: 
**********************************************************************************/
Shader "Unlit/PolygonClippingUnlitShader"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
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
                UNITY_FOG_COORDS(1)
                float2 worldPos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;
            float2 _Corners[20];
            int _CornerCount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //获得当前顶点世界坐标
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos.xyz;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float isLeftOfLine(float2 pos, float2 linePointStart, float2 linePointEnd)
            {
                //计算直线向量
                float2 lineDir = linePointEnd - linePointStart;
                //根据向量乘积定义，推算出法线（本方法使用左向的向量）
                float2 lineNormal = float2(-lineDir.y,lineDir.x);
                //从直线上一点指向给定点的向量
                float2 toPos = pos - linePointStart;
                //判断给定点在直线的哪一侧
                float side = dot(toPos, lineNormal);
                //返回（x >= a）? 1 : 0 （1：左；0：右）
                side = step(0, side);
                return side;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                /*-------------------------------------------Ares执行代码----------------------------------------------*/
                float outsideTriangle = 0;
                //循环计算每两个顶点连成的线，
                for(int index; index < _CornerCount; index++)
                {
                    //最后一个点和第一个点进行连线
                    outsideTriangle += isLeftOfLine(i.worldPos.xy, _Corners[index], _Corners[(index + 1) % _CornerCount]);
                }
                //负数则剔除（几何内部值的和为零，所以取负以后不为零的则在几何外侧）
                clip(-outsideTriangle);
                return _Color;
            }

            
            ENDCG
        }
    }
}
