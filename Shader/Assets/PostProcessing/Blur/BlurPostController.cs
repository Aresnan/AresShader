using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlurPostController : MonoBehaviour
{
    [SerializeField]
    private Material postprocessMaterial;
    private Camera cam;
    void Start()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //第四个参数代表shader中Pass的索引
        var temporaryTexture = RenderTexture.GetTemporary(source.width, source.height);
        //Graphics.Blit(source, temporaryTexture, postprocessMaterial, 0);
        //Graphics.Blit(temporaryTexture, destination, postprocessMaterial, 1);
        //RenderTexture.ReleaseTemporary(temporaryTexture);

        Graphics.Blit(source, destination, postprocessMaterial, 0);
    }
}
