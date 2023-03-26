using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asteroid : MonoBehaviour
{
    //parametr prêdkoœci ruchu
    public float speed;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        //poruszanie siê w dó³ z okreœlon¹ prêdkoœci¹
        transform.Translate(Vector3.down * speed* Time.deltaTime);
    }
    //niszczenie obiektu gdy spadnie poni¿ej widoku kamery
    private void OnBecameInvisible()
    {
        Destroy(gameObject);
    }
}
