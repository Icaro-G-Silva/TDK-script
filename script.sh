#!/bin/bash

main() {
  #Initialization
  $_warnings=""
  $_loop=1
  install_figlet_themagic
  
  #Main Display
  tsunami_art
  echo "Para começar a configurar o ambiente em seu computador aperte qualquer tecla"
  echo "OBS:Em alguns momentos é possível que seja pedido autorização de instalação ou versões de programas"
  read
  
  #Instalation process
  #basic_apt_checkout
  install_utilities
  install_git
  install_java
  install_maven
  install_docker

  #Warning display
  tsunami_art
  echo "Processo finalizado"
  if [[ -z $_warnings ]];
  then
    echo "Warnings: $_warnings"
  else
    echo "Tudo ocorreu bem"
  fi
  
  #Clone process
  ask_clone
  
  #Finish Display
  echo "Tudo feito!"
  echo ""
}

ask_clone() {
  while [[ "$_loop" -eq 1 ]];
  do
    echo "Deseja clonar os repositórios[Tsunami/Wavez]? (y/n)"
    read _option;
    case $_option in
      "y")
         cloning_repos
         $_loop=0
         ;;
      "Y")
         cloning_repos
         $_loop=0
         ;;
      "s")
         cloning_repos
         $_loop=0
         ;;
      "S")
         cloning_repos
         $_loop=0
         ;;
      "n")
         $_loop=0
         ;;
      "N")
         $_loop=0
         ;;
      *)
         echo "Opção inválida, tente novamente"
         ;;
    esac
  done
}

install_figlet_themagic() {
  apt install figlet -y
}

tsunami_art() {
  _tsunami_title="TSUNAMI DEVELOPMENT KIT"
  clear
  if ! figlet -tck $_tsunami_title
  then
    echo ""
    echo $_tsunami_title
    echo ""
  fi
}

basic_apt_checkout() {
  echo "Atualizando os repositórios"
  if ! apt update
  then
    echo "Não foi possível atualizar todos os repositórios. Verifique seu arquivo /etc/apt/sources.list"
  else
    echo "Repositórios atualizados"
  fi
  
  echo "Atualizando pacotes já instalados"
  if ! apt dist-upgrade -y
  then
    echo "Não foi possível atualizar os pacotes"
  else
    echo "Pacotes atualizados"
  fi 
}

install_java() {
  if which java
  then
    $_warnings="$_warnings Java já instalado configure manualmente;"
  else
    if [ $# -gt 1 ];
    then
      $_java_version=$1
    else
      echo "Selecione qual versão do Java gostaria de instalar"
      echo "1) Java 8"
      echo "2) Java 11"
      read _option;
      case $_option in
        "1")
	   $_java_version=openjdk-8-jdk
	   $_java_path=/usr/lib/jvm/java-8-openjdk-amd64
	   ;;
        "2")
           $_java_version=openjdk-11-jdk
	   $_java_path=/usr/lib/jvm/java-11-openjdk-amd64
	   ;;
      esac
    fi
    echo "Instalando o Java"
    if ! apt install $_java_version -y
    then
      $_warnings="$_warnings Não foi possível instalar o Java;"
    else
      echo "Java Instalado"
    fi
    configure_java
  fi
}

configure_java() {
  echo "Configurando o Java"
  if which java
  then
    if ! find $_java_path
    then
      $_warnings="$_warnings Caminho do java não encontrado, configure manualmente;"
    else
      echo "PATH=$_java_path/bin:$PATH" > /etc/environment
      echo "JAVA_HOME=$_java_path" >> /etc/environment
    fi
  else
    echo "Java não instalado, tente novamente"
  fi
  source /etc/environment
  echo "Java configurado"
}

install_docker() {
  if ! docker -v
  then
    echo "Instalando Docker"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt install docker-ce docker-ce-cli containerd.io -y
    if ! docker -v
    then
      $_warnings="$_warnings Não foi possivel instalar o Docker;"
    else
      echo "Docker instalado"
    fi
  else
    echo "Docker ja instalado"
  fi
  configure_docker
}

configure_docker() {
  if ! docker images postgres
  then
    echo "Configurando o Docker (postgres)"
    if ! docker pull postgres
    then
      $_warnings="$_warnings Não foi possivel configurar o Docker (postgres);"
    else
      echo "Docker configurado (postgres)"
    fi
  else
    echo "Docker já configurado"
  fi
}

install_utilities() {
  echo "Instalando utilitários"
  if ! apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
  then
    echo "Não foi possível instalar todos os utilitários"
  else
    echo "Utilitários instalados"
  fi
}

install_maven() {
  if ! apt install maven -y
  then
    $_warnings="$_warnings Não foi possível instalar o Maven;"
  else
    echo "Maven instalado"
  fi
}

install_git() {
  if ! apt install git -y
  then
    $_warnings="$_warnings Não foi possível instalar o Git;"
  else
    echo "Git instalado"
  fi
}

cloning_repos() {
  cd ~
  mkdir dextra-repos
  cd dextra-repos
  if ! git clone https://github.com/dextra/tsunami.git
  then
    echo "Não foi possível clonar o repositório do tsunami"
  else
    echo "Repositório do tsunami clonado dentro da home"
  fi
  if ! git clone https://github.com/dextra/my-way.git
  then
    echo "Não foi possível clonar o repositório do wavez"
  else
    echo "Repositório do wavez clonado dentro da home"
  fi
}

main

