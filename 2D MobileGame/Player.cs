using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;
using TMPro;

public class Player : MonoBehaviour
{
    //parametry wej�ciowe
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
        // Poruszanie si� w osi X za pomoc� kontrolera postaci
        Vector3 acceleration = Accelerometer.current.acceleration.ReadValue();

        Vector3 moveDirection = new(acceleration.x * movementSpeed * Time.deltaTime, 0, 0);

        Vector3 transformedDirection = transform.TransformDirection(moveDirection);

        characterController.Move(transformedDirection);
        //zmiana pozycji ograniczona do wielko�ci ekranu �eby nie wyjecha� poza
        transform.position = new Vector3(Mathf.Clamp(transform.position.x, -7f, 7f), transform.position.y, transform.position.z);
    }
    // czekanie mi�dzy ostatnim �yciem a restartem gry
    IEnumerator waiter()
    {
        yield return new WaitForSeconds(5);

    }
    // sprawdzanie kolizji z ateroid�
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Asteroid"))
        {

            Debug.Log(lives);
            //wywo�anie eksplozji
            playExplosion();
            //walidacja liczby �y�
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
    //funkcja wywo�uj�ca eksplozje
    void playExplosion()
    {
        GameObject e = Instantiate(explosion) as GameObject;
        e.transform.position = transform.position;
        //czas trwania eksplozji
        Destroy(e, 1.0f);
    }
}
