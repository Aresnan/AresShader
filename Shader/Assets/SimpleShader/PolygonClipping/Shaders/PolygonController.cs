/********************************************************************************* 
  *Author:      Aresnan
  *Version:     1.0
  *Date:        2021.10.12
  *Description: PolygonController，用于给PolygonClippingUnlitShader输入Inspector中的变量值
  *Function List: 
**********************************************************************************/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof (Renderer))]
public class PolygonController : MonoBehaviour
{
    [SerializeField]
    private Vector2[] corners;

    private Material _mat;

    void Start()
    {
        UpdateMaterial();
    }

    void OnValidate()
    {
        UpdateMaterial();
    }

    void UpdateMaterial()
    {
        if (_mat == null) _mat = GetComponent<Renderer>().sharedMaterial;

        //通知shader当前勾画的图形顶点
        Vector4[] vec4Corners = new Vector4[100];
        for (int i = 0; i < corners.Length; i++)
        {
            vec4Corners[i] = corners[i];
        }

        //shader只接受vector类型
        _mat.SetVectorArray("_Corners", vec4Corners);
        _mat.SetInt("_CornerCount", corners.Length);
    }
}
