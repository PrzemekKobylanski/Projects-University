using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asteroid : MonoBehaviour
{
    //parametr pr�dko�ci ruchu
    public float speed;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        //poruszanie si� w d� z okre�lon� pr�dko�ci�
        transform.Translate(Vector3.down * speed* Time.deltaTime);
    }
    //niszczenie obiektu gdy spadnie poni�ej widoku kamery
    private void OnBecameInvisible()
    {
        Destroy(gameObject);
    }
}
