using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;
using TMPro;
using Gyroscope = UnityEngine.InputSystem.Gyroscope;

public class GameManager : MonoBehaviour
{
    //parametry wejœciowe
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
    //obs³uga spawn pointu asteroid
    IEnumerator spawnAsteroid()
    {
        while(true)
        {
            //po³o¿enie spawnowanej asteroidy na okreœlonym miejscu dla ró¿nych x z zakresu aby by³y w widoku
            Vector3 spawnPoint=new Vector3 (Random.Range(-7f, 7f), 10, 12);
            //wybór randomowej asteroidy do spawnu
            int randEnemy = Random.Range(0, rand_asteroid.Length);
            //czas miêdzy spawnami
            float waitTime = Random.Range(0.5f, 1.5f);
            //zwiêkszenie poziomu trudnoœci przy okreœlonym wyniku
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

    //dodawanie punktów
    void scoreUp()
    {
        score++;
        ScoreText.text = score.ToString();
    }
    // inicjalizacja ¿yroskopu telefonu
    IEnumerator InitializeGyro()
    {
        Input.gyro.enabled = true;
        yield return null;
        Debug.Log(Input.gyro.attitude); // attitude has data now

    }
    //obs³uga startu gry
    public void GameStart()
    {
        //inicjalizacja akcelerometru i ¿yroskopu
        InputSystem.EnableDevice(Accelerometer.current);
        InputSystem.EnableDevice(AttitudeSensor.current);
        InputSystem.EnableDevice(Gyroscope.current);

        // StartCoroutine(InitializeGyro());
        //w³¹czenie widoku gracza, wy³¹czenie przycisku start i rozpoczêcie spawnowania rywali oraz naliczania punktów
        Player.SetActive(true);
        StartGame.SetActive(false);
        StartCoroutine("spawnAsteroid");
        InvokeRepeating("scoreUp",2f,1);

    }
}
