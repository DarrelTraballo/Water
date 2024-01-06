using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Squeegee
{
    [RequireComponent(typeof(MeshFilter))]
    public class Wave : MonoBehaviour
    {
        public int dimensions;
        public Material material;

        private Mesh mesh;
        private MeshRenderer meshRenderer;

        private Vector3[] vertices;
        private int[] triangles;

        private void GeneratePlane()
        {
            GetComponent<MeshFilter>().mesh = mesh = new Mesh();

            CreateShape();
            UpdateMesh();
        }

        private void CreateShape()
        {
            vertices = new Vector3[(dimensions + 1) * (dimensions + 1)];

            for (int i = 0, z = 0; z <= dimensions; z++)
            {
                for (int x = 0; x <= dimensions; x++)
                {
                    vertices[i] = new Vector3(x, 0, z);
                    i++;
                }
            }      

            triangles = new int[dimensions * dimensions * 6];
            int verts = 0;
            int tris = 0;

            for (int z = 0; z < dimensions; z++)
            {
                for (int x = 0; x < dimensions; x++)
                {
                    triangles[tris + 0] = verts + 0;
                    triangles[tris + 1] = verts + dimensions + 1;
                    triangles[tris + 2] = verts + 1;
                    triangles[tris + 3] = verts + 1;
                    triangles[tris + 4] = verts + dimensions + 1;
                    triangles[tris + 5] = verts + dimensions + 2;
                    
                    verts++;
                    tris += 6;
                }
                verts++;
            }
        }

        private void UpdateMesh()
        {
            meshRenderer = GetComponent<MeshRenderer>();

            mesh.Clear();
            mesh.vertices = vertices;
            mesh.triangles = triangles;

            mesh.RecalculateNormals();

            meshRenderer.material = material;
        }

        private void OnEnable()
        {
            GeneratePlane();
        }

        #if UNITY_EDITOR
        private void OnDrawGizmos()
        {
            // DrawVertices();
        }

        private void DrawVertices()
        {
            if (vertices == null) return;

            for (int i = 0; i < vertices.Length; i++)
            {
                Gizmos.DrawSphere(vertices[i], 0.1f);
            }
        }
        #endif
    }
}
