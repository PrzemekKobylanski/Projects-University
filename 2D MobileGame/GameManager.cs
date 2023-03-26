using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;
using TMPro;
using Gyroscope = UnityEngine.InputSystem.Gyroscope;

public class GameManager : MonoBehaviour
{
    //parametry wej�ciowe
    int score = 0;
    public TMPro.TextMeshProUGUI ScoreText;
    public GameObject StartGame;
    public GameObject Player;
    public GameObject[] rand_asteroid;

    // Start is called before the first frame update
    void Start()
    {
       // GameStart();

    }

    // Update is called once per frame
    void Update()
    {
        
    }
    //obs�uga spawn pointu asteroid
    IEnumerator spawnAsteroid()
    {
        while(true)
        {
            //po�o�enie spawnowanej asteroidy na okre�lonym miejscu dla r�nych x z zakresu aby by�y w widoku
            Vector3 spawnPoint=new Vector3 (Random.Range(-7f, 7f), 10, 12);
            //wyb�r randomowej asteroidy do spawnu
            int randEnemy = Random.Range(0, rand_asteroid.Length);
            //czas mi�dzy spawnami
            float waitTime = Random.Range(0.5f, 1.5f);
            //zwi�kszenie poziomu trudno�ci przy okre�lonym wyniku
            if(score>50)
            {
                waitTime = Random.Range(0.2f, 1f);
            }
            if(score>100)
            {
                waitTime = Random.Range(0.1f, 0.5f);
            }
            yield return new WaitForSeconds(waitTime);
            //inicjalizacja asteroidy
            Instantiate(rand_asteroid[randEnemy],spawnPoint, Quaternion.identity);
        }
    }

    //dodawanie punkt�w
    void scoreUp()
    {
        score++;
        ScoreText.text = score.ToString();
    }
    // inicjalizacja �yroskopu telefonu
    IEnumerator InitializeGyro()
    {
        Input.gyro.enabled = true;
        yield return null;
        Debug.Log(Input.gyro.attitude); // attitude has data now

    }
    //obs�uga startu gry
    public void GameStart()
    {
        //inicjalizacja akcelerometru i �yroskopu
        InputSystem.EnableDevice(Accelerometer.current);
        InputSystem.EnableDevice(AttitudeSensor.current);
        InputSystem.EnableDevice(Gyroscope.current);

        // StartCoroutine(InitializeGyro());
        //w��czenie widoku gracza, wy��czenie przycisku start i rozpocz�cie spawnowania rywali oraz naliczania punkt�w
        Player.SetActive(true);
        StartGame.SetActive(false);
        StartCoroutine("spawnAsteroid");
        InvokeRepeating("scoreUp",2f,1);

    }
}
