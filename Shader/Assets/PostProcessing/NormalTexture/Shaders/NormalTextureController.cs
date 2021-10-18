using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NormalTextureController : MonoBehaviour
{
    [SerializeField]
    private Material postprocessMaterial;
    private Camera cam;
    void Start()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Matrix4x4 matrix = cam.cameraToWorldMatrix;
        postprocessMaterial.SetMatrix("_Matrix", matrix);
        Graphics.Blit(source, destination, postprocessMaterial);
    }
}
