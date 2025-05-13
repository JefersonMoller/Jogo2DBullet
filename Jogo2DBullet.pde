import processing.sound.*;
import javax.swing.JOptionPane;
import java.io.*;
import java.util.ArrayList;

// ======== VARIÁVEIS GERAIS ========
String nome = "";
int telaAtual = 0; // 0 = Cadastro, 1 = Jogo

// ======== VARIÁVEIS DO JOGO ========
SoundFile musicaNave;
SoundFile somTiro;
SoundFile somExplosao;

PImage fundo, nave, laserImg, explosaoImg, meteoroImg;
float naveX, naveY;
float velocidadeNave = 5;
float fundoX1 = 0;
float fundoX2;
float velocidadeFundo = 2;

ArrayList<Tiro> tiros = new ArrayList<Tiro>();
ArrayList<Meteoro> meteoros = new ArrayList<Meteoro>();

boolean jogoAtivo = true;

void setup() {
  size(1200, 800);
  windowTitle("Cadastro e Jogo");
  fundoX2 = width;
}

void draw() {
  if (telaAtual == 0) {
    telaCadastro();
  } else if (telaAtual == 1) {
    telaJogo();
  }
}

void telaCadastro() {
  background(159, 162, 16);

  textSize(20);
  fill(255);
  textAlign(CENTER);
  text("Informe seu nome:", width / 2, 100);

  // Caixa para digitar jogador
  stroke(0);
  noFill();
  rect(width/2 - 100, 150, 200, 40);

  fill(255);
  textAlign(LEFT, CENTER);
  text(nome, width/2 - 90, 170);

  // Botão "JOGAR"
  fill(70, 150, 70);
  rect(width/2 - 50, 220, 100, 40);
  fill(255);
  textAlign(CENTER, CENTER);
  text("JOGAR", width/2, 240);
}

void telaJogo() {
  if (!jogoAtivo) {
    background(0);
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(50);
    text("GAME OVER", width/2, height/2);
    return;
  }

  // Initialize the game
  if (musicaNave == null) {
    // Load images
    fundo = loadImage("assets/images/FundoMundo.jpg");
    nave = loadImage("assets/images/extra.png");
    laserImg = loadImage("assets/images/laser_tiro.png");
    explosaoImg = safeLoadImage("assets/images/explosao.png");
    meteoroImg = safeLoadImage("assets/images/meteoro.png");
    nave.resize(80, 80);
    laserImg.resize(200, 100);
    if (meteoroImg != null) meteoroImg.resize(60, 60);
    
    // Load sounds
    try {
      musicaNave = safeLoadSound("assets/sounds/naveSonoro.MP3");
      somTiro = safeLoadSound("assets/sounds/tiro_N1.MP3");
      somExplosao = safeLoadSound("assets/sounds/explosao2.mp3");
      musicaNave.loop();
    } catch (Exception e) {}
    naveX = width/2 - nave.width/2;
    naveY = height/2 - nave.height/2;
    fundoX2 = fundo.width;
  }

  background(0);

  // Movimento do fundo
  fundoX1 -= velocidadeFundo;
  fundoX2 -= velocidadeFundo;
  image(fundo, fundoX1, 0);
  image(fundo, fundoX2, 0);
  if (fundoX1 < -fundo.width) fundoX1 = fundoX2 + fundo.width;
  if (fundoX2 < -fundo.width) fundoX2 = fundoX1 + fundo.width;

  // Movimento nave
  if (keyPressed && key == CODED) {
    if (keyCode == LEFT) naveX -= velocidadeNave;
    if (keyCode == RIGHT) naveX += velocidadeNave;
    if (keyCode == UP) naveY -= velocidadeNave;
    if (keyCode == DOWN) naveY += velocidadeNave;
  }

  naveX = constrain(naveX, 0, width - nave.width);
  naveY = constrain(naveY, 0, height - nave.height);
  image(nave, naveX, naveY);

  // Atualiza tiros
  for (int i = tiros.size() - 1; i >= 0; i--) {
    Tiro t = tiros.get(i);
    t.atualizar();
    t.mostrar();
    if (t.x > width) tiros.remove(i);
  }

  // Atualiza meteoros
  if (frameCount % 60 == 0) meteoros.add(new Meteoro());
  for (int i = meteoros.size() - 1; i >= 0; i--) {
    Meteoro m = meteoros.get(i);
    m.atualizar();
    m.mostrar();

    // Colisão nave
    if (dist(m.x, m.y, naveX + nave.width/2, naveY + nave.height/2) < 40) {
      jogoAtivo = false;
      if (somExplosao != null) somExplosao.play();
      if (explosaoImg != null) image(explosaoImg, naveX, naveY);
      break;
    }

    // Colisão tiro
    for (int j = tiros.size() - 1; j >= 0; j--) {
      Tiro t = tiros.get(j);
      if (dist(m.x, m.y, t.x, t.y) < 40) {
        if (somExplosao != null) somExplosao.play();
        if (explosaoImg != null) image(explosaoImg, m.x, m.y);
        meteoros.remove(i);
        tiros.remove(j);
        break;
      }
    }

    if (m.x < -50) meteoros.remove(i);
  }
}

void mousePressed() {
  if (telaAtual == 0) {
    if (mouseX >= width/2 - 50 && mouseX <= width/2 + 50 &&
        mouseY >= 220 && mouseY <= 260) {
      if (nome.length() > 0) {
        println("Jogador cadastrado: " + nome);
        JOptionPane.showMessageDialog(null, "Iniciando o jogo", "Informação", JOptionPane.INFORMATION_MESSAGE);
        telaAtual = 1;
      } else {
        JOptionPane.showMessageDialog(null, "Jogador não cadastrado! Você deve cadastrar um jogador!", "Alerta", JOptionPane.INFORMATION_MESSAGE);
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
  }
}

void atirar() {
  if (somTiro.isPlaying()) somTiro.stop();
  somTiro.play();
  float tiroX = naveX + nave.width - 5;
  float tiroY = naveY + nave.height - laserImg.height - 5;
  tiros.add(new Tiro(tiroX, tiroY, laserImg));
}

class Tiro {
  float x, y;
  float velocidade = 12;
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
  float velocidadeX = random(3, 7);
  float velocidadeY = random(-1.5, 1.5);
  Meteoro() {
    x = width + 50;
    y = random(50, height - 50);
  }
  void atualizar() {
    x -= velocidadeX;
    y += velocidadeY;
  }
  void mostrar() {
    if (meteoroImg != null) {
      image(meteoroImg, x, y);
    } else {
      fill(255, 100, 0);
      ellipse(x, y, 40, 40);
    }
  }
}

PImage safeLoadImage(String path) {
  try {
    return loadImage(path);
  } catch (Exception e) {
    println("Erro ao carregar imagem: " + path);
    return null;
  }
}

SoundFile safeLoadSound(String path) {
  try {
    return new SoundFile(this, path);
  } catch (Exception e) {
    println("Error loading sound: " + path);
    println("Exception: " + e);
    println("Running in silent mode");
    return null;
  }
}