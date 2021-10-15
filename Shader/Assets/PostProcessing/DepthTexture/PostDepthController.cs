using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostDepthController : MonoBehaviour
{
    [SerializeField]
    private Material postprocessMaterial;
    void Start()
    {
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {        
        //postprocessMaterial.SetFloat("_WaveDistance", waveDistance);
        Graphics.Blit(source, destination, postprocessMaterial);
    }
}
