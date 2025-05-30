import processing.sound.*; //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
import javax.swing.JOptionPane;
import java.io.*;
import java.util.ArrayList;
import java.util.Collections;

String nome = "";
int pontuacaoJogador = 0;
int telaAtual = 0; // 0 = Cadastro, 1 = Jogo
int tempoInicial;
float multiplicaVeloc = 1.0;
//int[] pontuacaoAcumulada2 = new int[5]; //para Score
// troca
ArrayList<Integer> pontuacaoAcumulada = new ArrayList<Integer>();

int jogadaAtual = 0;

SoundFile musicaNave;
SoundFile somTiro;
SoundFile somExplosao;

PFont minhaFOnte, fontePadrao;
PImage fundo, nave, laserImg, explosaoImg, meteoroImg, gameOver, estrelaImg;
float naveX, naveY;
float velocidadeNave = 5;
float fundoX1 = 0;
float fundoX2;
float velocidadeFundo = 2;

ArrayList<Tiro> tiros = new ArrayList<Tiro>();
ArrayList<Meteoro> meteoros = new ArrayList<Meteoro>();

boolean jogoAtivo = true;
boolean imune = false;
int tempoImunidade = 0;
boolean piscar = false;

// Variáveis para a estrela
int tempoUltimaEstrela = 0;
Estrela estrelaPoder; // Objeto da classe Estrela

void setup() {
  size(1200, 800);
  windowTitle("Cadastre seu jogador");
  fundoX2 = width;
  fundo = loadImage("apresentacao2.png");
  gameOver = loadImage("gameOverSangrento.png");
  estrelaImg = loadImage("estrela.gif");
  estrelaImg.resize(80, 80); //tamanho da estrela bonus

  minhaFOnte = createFont("HelpMe.ttf", 32);
  fontePadrao = createFont("arial", 32);

  if (gameOver != null) {
    gameOver.resize(1200, 800);
  }
}

void draw() {
  if (telaAtual == 0) {
    telaCadastro();
  } else if (telaAtual == 1) {
    telaJogo();
  }
}

void telaCadastro() {
  image(fundo, 0, 0, width, height);

  textSize(20);
  fill(255);
  textAlign(CENTER);
  textSize(25);
  text("Informe seu nome:", width / 2, 20);

  stroke(0);
  fill(240, 245, 15);
  rect(width/2 - 100, 50, 200, 40);

  fill(10, 10, 10);
  textAlign(CENTER, CENTER);//NOME CENTRALIZADO - NAO TEM LIMITE E ESTÁ PASSANDO DA CAIXA
  text(nome, width/2, 70);//NOME CENTRALIZADO - NAO TEM LIMITE E ESTÁ PASSANDO DA CAIXA

  fill(15, 245, 58);
  rect(width/2 - 50, 100, 100, 40);
  fill(5);
  textAlign(CENTER, CENTER);
  text("JOGAR", width/2, 120);
}

void telaJogo() {
  if (!jogoAtivo) {
    background(0);
    if (gameOver != null) {
      imageMode(CENTER);
      image(gameOver, width/2, height/2 - 150);
      imageMode(CORNER);
    }

    fill(255, 0, 0);
    textFont(minhaFOnte);
    textSize(65);
    text("GAME OVER", width/2, (height/2)-100);

    textFont(fontePadrao);
    fill(5, 149, 22);
    textSize(50);
     
    //JOgador e pontuação
    text("O jogador "+nome+"\nteve a pontuação de "+pontuacaoJogador, width/2, height/2);

    fill(255);
    textSize(30);
    text("Pressione enter para restart",width/2, height/2 + 300);
    return;
  }

  if (musicaNave == null) {
    fundo = loadImage("fundo.png");
    nave = loadImage("extra.png");
    laserImg = loadImage("laser_tiro.png");
    explosaoImg = loadImage("explosao.png");
    meteoroImg = loadImage("meteoro.png");
    nave.resize(80, 80);
    laserImg.resize(200, 100);
    if (meteoroImg != null) meteoroImg.resize(60, 60);

    musicaNave = new SoundFile(this, "naveSonoro.MP3");
    somTiro = new SoundFile(this, "tiro_N1.MP3");
    somExplosao = new SoundFile(this, "explosao2.mp3");
    musicaNave.loop();

    naveX = width/2 - nave.width/2;
    naveY = height/2 - nave.height/2;
    fundoX2 = fundo.width;

    tempoInicial = millis();
    tempoUltimaEstrela = millis();
  }

  int tempoDecorrido = millis() - tempoInicial;
  int minutosPassados = tempoDecorrido / 60000;
  multiplicaVeloc = 1.0 + minutosPassados * 0.9; // ajuste de velocidade e progresso do jogo

  background(0);
  fundoX1 -= velocidadeFundo;
  fundoX2 -= velocidadeFundo;
  image(fundo, fundoX1, 0);
  image(fundo, fundoX2, 0);
  if (fundoX1 < -fundo.width) fundoX1 = fundoX2 + fundo.width;
  if (fundoX2 < -fundo.width) fundoX2 = fundoX1 + fundo.width;

  if (keyPressed && key == CODED) {
    if (keyCode == LEFT) naveX -= velocidadeNave;
    if (keyCode == RIGHT) naveX += velocidadeNave;
    if (keyCode == UP) naveY -= velocidadeNave;
    if (keyCode == DOWN) naveY += velocidadeNave;
  }

  naveX = constrain(naveX, 0, width - nave.width);
  naveY = constrain(naveY, 0, height - nave.height);

  //Imunidade com estrela por 10 segndos
  if (imune && millis() - tempoImunidade > 10000) {
    imune = false;
  }

  if (imune) {
    if (frameCount % 10 < 5) {
      image(nave, naveX, naveY);
    }
  } else {
    image(nave, naveX, naveY);
  }

  if (frameCount % 60 == 0) meteoros.add(new Meteoro(multiplicaVeloc));
  for (int i = meteoros.size() - 1; i >= 0; i--) {
    Meteoro m = meteoros.get(i);
    m.atualizar();
    m.mostrar();

    if (!imune && dist(m.x, m.y, naveX + nave.width/2, naveY + nave.height/2) < 40) {
      jogoAtivo = false;
      if (somExplosao != null) somExplosao.play();
      if (explosaoImg != null) image(explosaoImg, naveX, naveY);
      break;
    }

    for (int j = tiros.size() - 1; j >= 0; j--) {
      Tiro t = tiros.get(j);
      if (dist(m.x, m.y, t.x, t.y) < 40) {
        if (somExplosao != null) somExplosao.play();
        if (explosaoImg != null) image(explosaoImg, m.x, m.y);
        meteoros.remove(i);
        tiros.remove(j);
        pontuacaoJogador += 1;
        break;
      }
    }

    if (m.x < -50) meteoros.remove(i);
  }

  for (int i = tiros.size() - 1; i >= 0; i--) {
    Tiro t = tiros.get(i);
    t.atualizar();
    t.mostrar();
    if (t.x > width) tiros.remove(i);
  }

  // Lógica da estrela: aparece a cada 1 minuto (60 * 1000 milissegundos)
  if (estrelaPoder == null || !estrelaPoder.ativa) {
    if (millis() - tempoUltimaEstrela > 60 * 1000) { // 1 minuto em milissegundos
      estrelaPoder = new Estrela(width + 50, random(100, height - 100)); // Começa à direita
      tempoUltimaEstrela = millis();
    }
  }

  if (estrelaPoder != null && estrelaPoder.ativa) {
    estrelaPoder.atualizar();
    estrelaPoder.mostrar();
  }
}

void mousePressed() {
  if (telaAtual == 0) {
    if (mouseX >= width/2 - 50 && mouseX <= width/2 + 50 &&
        mouseY >= 100 && mouseY <= 140) {
      if (nome.length() > 0 && nome.length() <=15) {
        telaAtual = 1;
      } else {
        JOptionPane.showMessageDialog(null, "Seu cadastro não foi preenchido ou passou do limite de 15 caracteres!", "Alerta", JOptionPane.INFORMATION_MESSAGE);
      }
    }
  } else {
    if (mouseButton == LEFT && jogoAtivo) {
      atirar();
    }
  }
}

void keyPressed() {
  if (telaAtual == 0) {
    if (key == BACKSPACE && nome.length() > 0) {
      nome = nome.substring(0, nome.length() - 1);
    } else if (key != CODED && nome.length() < 20 && key != ENTER && key != RETURN) {
      nome += key;
    }
  } else {
    if (key == ' ' && jogoAtivo) {
      atirar();
    }

    if (!jogoAtivo && (key == ENTER || key == RETURN)) {
      restart();
    }
  }

}

void restart() {
  pontuacaoJogador = 0;
  naveX = width/2 - nave.width/2;
  naveY = height/2 - nave.height/2;
  tiros.clear();
  meteoros.clear();
  jogoAtivo = true;
  multiplicaVeloc = 1.0;
  tempoInicial = millis();
  imune = false;
  
  estrelaPoder = null; // Garante que a estrela seja resetada
  tempoUltimaEstrela = millis(); // Reseta o contador para a próxima estrela
  
  if (musicaNave != null && !musicaNave.isPlaying()) {
    musicaNave.loop();
  }
}

void atirar() {
  if (somTiro != null && somTiro.isPlaying()) somTiro.stop();
  if (somTiro != null) somTiro.play();
  float tiroX = naveX + nave.width - 5;
  float tiroY = naveY + nave.height - laserImg.height - 5;
  tiros.add(new Tiro(tiroX, tiroY, laserImg));
}

class Tiro {
  float x, y;
  float velocidade = 15; //  controla velocidade do tiro - deve aumentar a cada ciclo de aumento de velocidade
  PImage img;
  Tiro(float x, float y, PImage img) {
    this.x = x;
    this.y = y;
    this.img = img;
  }
  void atualizar() {
    x += velocidade;
  }
  void mostrar() {
    image(img, x, y);
  }
}

class Meteoro {
  float x, y;
  float velocidadeX;
  float velocidadeY;
  Meteoro(float multiplicador) {
    x = width + 50;
    y = random(0, height - 60);
    velocidadeX = random(3, 6) * multiplicador;
    velocidadeY = random(-1, 1);
  }
  void atualizar() {
    x -= velocidadeX;
    y += velocidadeY;
    y = constrain(y, 0, height - 60);
  }
  void mostrar() {
    image(meteoroImg, x, y);
  }
}

// Nova classe para a estrela
class Estrela {
  float x, y;
  float velocidade = 3; // Velocidade da estrela
  boolean ativa;

  Estrela(float inicioX, float inicioY) {
    this.x = inicioX;
    this.y = inicioY;
    this.ativa = true;
  }

  void atualizar() {
    x -= velocidade; // Move da direita para a esquerda

    // Se a estrela sair da tela, desativa
    if (x < -estrelaImg.width) {
      ativa = false;
    }

    // Verifica colisão com a nave
    if (ativa && dist(naveX + nave.width/2, naveY + nave.height/2, x + estrelaImg.width/2, y + estrelaImg.height/2) < 40) {
      imune = true;
      tempoImunidade = millis();
      ativa = false; // Desativa a estrela após ser coletada
    }
  }

  void mostrar() {
    if (ativa) {
      image(estrelaImg, x, y);
    }
  }
}
