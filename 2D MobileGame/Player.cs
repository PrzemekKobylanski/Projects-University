using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;
using TMPro;

public class Player : MonoBehaviour
{
    //parametry wejœciowe
    [SerializeField]
    private float movementSpeed = 8.0f;
    private CharacterController characterController;
    int lives = 3;
    public TMPro.TextMeshProUGUI livesText;
    public GameObject explosion;
    // Start is called before the first frame update
    void Start()
    {
        //wczytanie komponentu kontrolera postaci
        characterController = GetComponent<CharacterController>();
    }
 
    // Update is called once per frame
    void Update()
    {
        Debug.Log(Input.gyro.attitude);
        // Poruszanie siê w osi X za pomoc¹ kontrolera postaci
        Vector3 acceleration = Accelerometer.current.acceleration.ReadValue();

        Vector3 moveDirection = new(acceleration.x * movementSpeed * Time.deltaTime, 0, 0);

        Vector3 transformedDirection = transform.TransformDirection(moveDirection);

        characterController.Move(transformedDirection);
        //zmiana pozycji ograniczona do wielkoœci ekranu ¿eby nie wyjechaæ poza
        transform.position = new Vector3(Mathf.Clamp(transform.position.x, -7f, 7f), transform.position.y, transform.position.z);
    }
    // czekanie miêdzy ostatnim ¿yciem a restartem gry
    IEnumerator waiter()
    {
        yield return new WaitForSeconds(5);

    }
    // sprawdzanie kolizji z ateroid¹
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Asteroid"))
        {

            Debug.Log(lives);
            //wywo³anie eksplozji
            playExplosion();
            //walidacja liczby ¿yæ
            lives -= 1;
            livesText.text = lives.ToString();
            //game over
            if (lives == 0)
            {
                StartCoroutine(waiter());
                SceneManager.LoadScene("MobileGame");

            }
        }

    }
    //funkcja wywo³uj¹ca eksplozje
    void playExplosion()
    {
        GameObject e = Instantiate(explosion) as GameObject;
        e.transform.position = transform.position;
        //czas trwania eksplozji
        Destroy(e, 1.0f);
    }
}
