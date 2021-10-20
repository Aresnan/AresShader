using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthOutlinesController : MonoBehaviour
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
        Graphics.Blit(source, destination, postprocessMaterial);
    }
}
