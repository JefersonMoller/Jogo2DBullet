import processing.sound.*;
import javax.swing.JOptionPane;
import java.io.*;
import java.util.ArrayList;
import java.util.Collections;

String nome = "";
int pontuacaoJogador = 0;
int telaAtual = 0; // 0 = Cadastro, 1 = Jogo
int tempoInicial;
float multiplicaVeloc = 1.0;
ArrayList<Integer> pontuacaoAcumulada = new ArrayList<Integer>();

int jogadaAtual = 0;

SoundFile musicaNave;
SoundFile somTiro;
SoundFile somExplosao;

PFont minhaFOnte, fontePadrao;
PImage fundo_cadastro, fundo, fundo2, fundo3, fundo4,nave, laserImg, explosaoImg, meteoroImg, meteoroImg2, poderFogo, gameOver, estrelaImg, fundoAtual; // Corrigido: meteoroImg2
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

  // Telas para troca de fundo do jogo
  fundo = loadImage("fundo.png");
  fundo2 = loadImage("fundo2.jpg");
  fundo3 = loadImage("fundo3.jpg");
  //fundo4 = loadImage("bosque.jpg");
  fundo4 = loadImage("bosque2.png");

  fundo_cadastro = loadImage("apresentacao3.png");
  gameOver = loadImage("gameOverSangrento.png");
  estrelaImg = loadImage("estrela.gif");
  estrelaImg.resize(80, 80); //tamanho da estrela bonus

  minhaFOnte = createFont("HelpMe.ttf", 32);
  fontePadrao = createFont("arial", 32);

  if (gameOver != null) {
    gameOver.resize(1200, 800);
  }

  nave = loadImage("extra.png");
  laserImg = loadImage("laser_tiro.png");
  explosaoImg = loadImage("explosao.png");

  //tipos de inimigos - meteoros ou poder do fogo
  meteoroImg = loadImage("meteoro.png");
  meteoroImg2 = loadImage("meteoro_2.png");
  poderFogo = loadImage("poderFogo.png");

  nave.resize(80, 80);
  laserImg.resize(200, 50); // Redimensionado para ficar mais próximo do centro da nave

  if (meteoroImg != null) meteoroImg.resize(60, 60);
  if (meteoroImg2 != null) meteoroImg2.resize(130, 130);
  if (poderFogo != null) poderFogo.resize(130, 130);
}

void draw() {
  if (telaAtual == 0) {
    telaCadastro();
  } else if (telaAtual == 1) {
    telaJogo();
  }
}

void telaCadastro() {
  image(fundo_cadastro, 0, 0, width, height);

  textSize(20);
  fill(255);
  textAlign(CENTER);
  textSize(25);
  text("Informe seu nome:", width / 2, 20);

  stroke(0);
  fill(240, 245, 15);
  rect(width/2 - 100, 50, 200, 40);

  fill(10, 10, 10);
  textAlign(CENTER, CENTER);
  text(nome, width/2, 70);

  fill(15, 245, 58);
  rect(width/2 - 50, 100, 100, 40);
  fill(5);
  textAlign(CENTER, CENTER);
  text("JOGAR", width/2, 120);
}

void telaJogo() {

  int tempoFundo = (millis() - tempoInicial) / 1000;


  //neste bloco, alterna a imagem de fundo com o passar do tempo
  if (tempoFundo < 90) { // troca do primeiro fundo em 1min e 30s
    fundoAtual = fundo4;
  } else if (tempoFundo < 180) {// 3min
    fundoAtual = fundo2;
  } else if (tempoFundo < 240){
    fundoAtual = fundo3;
  }else{
    fundoAtual = fundo;
  }

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
    text("GAME OVER", (width/2)-210, (height/2)-100);

    textFont(fontePadrao);
    fill(5, 149, 22);
    textSize(50);

    //JOgador e pontuação
    text("O jogador " + nome + "\nteve a pontuação de " + pontuacaoJogador, (width/2)-210, height/2);

    fill(255);
    textSize(30);
    text("Pressione enter para restart", width/2, height/2 + 300);
    return;
  }

  if (musicaNave == null) {
    musicaNave = new SoundFile(this, "naveSonoro.MP3");
    somTiro = new SoundFile(this, "tiro_N1.MP3");
    somExplosao = new SoundFile(this, "explosao2.mp3");
    musicaNave.loop();

    naveX = width/2 - nave.width/2;
    naveY = height/2 - nave.height/2;

    tempoInicial = millis();
    tempoUltimaEstrela = millis();
  }

  int tempoDecorrido = millis() - tempoInicial;
  int minutosPassados = tempoDecorrido / 60000;
  multiplicaVeloc = 1.0 + minutosPassados * 0.9; // ajuste de velocidade e progresso do jogo

  background(0);
  fundoX1 -= velocidadeFundo;
  fundoX2 -= velocidadeFundo;
  image(fundoAtual, fundoX1, 0);
  image(fundoAtual, fundoX2, 0);
  if (fundoX1 < -fundoAtual.width) fundoX1 = fundoX2 + fundoAtual.width;
  if (fundoX2 < -fundoAtual.width) fundoX2 = fundoX1 + fundoAtual.width;

  //controle da nave com direcionais
  if (keyPressed && key == CODED) {
    if (keyCode == LEFT) naveX -= velocidadeNave;
    if (keyCode == RIGHT) naveX += velocidadeNave;
    if (keyCode == UP) naveY -= velocidadeNave;
    if (keyCode == DOWN) naveY += velocidadeNave;
  }

  //controle da nave com A,S,D,W
  if (keyPressed) {
    if (key == 'a' || key == 'A') naveX -= velocidadeNave;
    if (key == 'd' || key == 'D') naveX += velocidadeNave;
    if (key == 'w' || key == 'W') naveY -= velocidadeNave;
    if (key == 's' || key == 'S') naveY += velocidadeNave;
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

    // Verificação de colisão da nave com o meteoro
    if (!imune && dist(m.x + m.imagemAtualDoMeteoro.width/2, m.y + m.imagemAtualDoMeteoro.height/2, naveX + nave.width/2, naveY + nave.height/2) < (nave.width/2 + m.imagemAtualDoMeteoro.width/2) * 0.7) {
      jogoAtivo = false;
      if (somExplosao != null) somExplosao.play();
      if (explosaoImg != null) {
        imageMode(CENTER);
        image(explosaoImg, naveX + nave.width/2, naveY + nave.height/2);
        imageMode(CORNER);
      }
      break;
    }

    // Verificação de colisão do tiro com o meteoro
    for (int j = tiros.size() - 1; j >= 0; j--) {
      Tiro t = tiros.get(j);
      if (dist(m.x + m.imagemAtualDoMeteoro.width/2, m.y + m.imagemAtualDoMeteoro.height/2, t.x + t.img.width/2, t.y + t.img.height/2) < (m.imagemAtualDoMeteoro.width/2 + t.img.width/2) * 0.7) {
        if (somExplosao != null) somExplosao.play();
        if (explosaoImg != null) {
          imageMode(CENTER);
          image(explosaoImg, m.x + m.imagemAtualDoMeteoro.width/2, m.y + m.imagemAtualDoMeteoro.height/2);
          imageMode(CORNER);
        }
        meteoros.remove(i);
        tiros.remove(j);
        pontuacaoJogador += 1;
        break;
      }
    }

    if (m.x < -150) meteoros.remove(i); // Remove meteoros que saem da tela
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

  // Exibir pontuação
  fill(255);
  textSize(24);
  textAlign(LEFT, TOP);
  text("Pontuação: " + pontuacaoJogador, 10, 10);
  text("Tempo: " + tempoFundo + "s", 10, 40);
  text("Velocidade: " + String.format("%.1f", multiplicaVeloc) + "x", 10, 70);
  text("Imunidade: " + (imune ? "ATIVADA" : "DESATIVADA"), 10, 100);
}

void mousePressed() {
  if (telaAtual == 0) {
    if (mouseX >= width/2 - 50 && mouseX <= width/2 + 50 &&
      mouseY >= 100 && mouseY <= 140) {
      if (nome.length() > 0 && nome.length() <= 15) {
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
    } else if (key != CODED && nome.length() < 15 && key != ENTER && key != RETURN) { // Limite de 15 caracteres
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
  // Ajuste a posição Y do tiro para que ele saia mais centralizado na nave
  float tiroX = naveX + nave.width;
  float tiroY = naveY + nave.height / 2 - laserImg.height / 2;
  tiros.add(new Tiro(tiroX, tiroY, laserImg));
}

class Tiro {
  float x, y;
  float velocidade = 15; //controla velocidade do tiro - deve aumentar a cada ciclo de aumento de velocidade
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
  PImage imagemAtualDoMeteoro; // Variável para armazenar a imagem específica deste meteoro
  int tipo; // Adicionado: variável 'tipo' para determinar o tipo de meteoro

  Meteoro(float multiplicador) {
    x = width + 50;
    y = random(0, height - 60);
    velocidadeX = random(3, 6) * multiplicador;
    velocidadeY = random(-1, 1);

    // Atribui um tipo aleatoriamente
    tipo = (int) random(3); // 0, 1 ou 2

    if (tipo == 0) {
      this.imagemAtualDoMeteoro = meteoroImg;
    } else if (tipo == 1) {
      this.imagemAtualDoMeteoro = meteoroImg2;
    } else { // tipo == 2
      this.imagemAtualDoMeteoro = poderFogo;
    }
  }

  void atualizar() {
    x -= velocidadeX;
    y += velocidadeY;
    y = constrain(y, 0, height - imagemAtualDoMeteoro.height); // Garante que o meteoro não saia da tela verticalmente
  }

  void mostrar() {
    image(imagemAtualDoMeteoro, x, y);
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
    // Ajustado o cálculo de distância para considerar o centro das imagens
    if (ativa && dist(naveX + nave.width/2, naveY + nave.height/2, x + estrelaImg.width/2, y + estrelaImg.height/2) < (nave.width/2 + estrelaImg.width/2) * 0.7) { // Multiplicador para ajuste de colisão
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