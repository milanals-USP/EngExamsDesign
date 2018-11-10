%By Milana Lima dos Santos

clear all

%Find the name of this script, so the generated files should have the same name
nomearqm=strrep(mfilename(),'_','');

%Intended number of lines in csv file (different sets of input data)
lines=8;

sorteiocomrepeticao=false;

faixaexatogeral=0.005; %Normalized range within which the answer is considered as correct
margemgeral=0.02; 
% if the answer is out of the range of 'faixaexatogeral' and within the range of 'margemgeral',
% the score is subject to a penalty. Out of 'margemgeral', the score of this question is zero
toleranciaultimodigitogeral=false; %simply accepts a variation of +-1 in the last digit


%% Defini��o de dados de entrada
%Entrada
%Nesse problema, n�o h� combina��es entre os vetores, e sim um total de n
%combina��es bem definidas de par�metros, na matriz 'entrada'

entrada={
   '110',   '2', '4', '300'
   '127',   '1', '3', '280'
   '220',   '2', '3', '400' 
    };
 
label_entrada={
    'V','ITwo', 'IThree',  'PThree'
    };

enun_problema={
    'In the following circuit, where source voltage is $V_s$ = \V~V, current and active power measurements were taken:'
    '\begin{itemize}'
    '\item $I_2$ = \ITwo~A;'
    '\item $I_3$ = \IThree~A;'
    '\item $P_3$ = \PThree~W (measured in RL branch)'
    '\end{itemize}'
    ' '
    '\begin{figure}[htb!]'
    '\centering'
    '\includegraphics{drawing1.pdf}'
    '\caption{\footnotesize{Circuit}}'
    ['\label{fig:circuito', nomearqm,'}']
    '\end{figure}'
    ' '
    };


%% Defini��o de diferentes combina��es de perguntas e quantidade de colunas de componentes no .csv,

%% Enunciados das quest�es

%N�o precisa usar aspas duplas nos enunciados, o programa vai inseri-las
%mais adiante

%enunciados das quest�es
qtde_opcoes_enunciados=3;

enunciados=cell(qtde_opcoes_enunciados,1);
c=1;enunciados{c}=['Find the magnitude for current $I_1$, in amperes.'];
c=2;enunciados{c}=['Find the power factor in the RL branch (leading or lagging).'];
c=3;enunciados{c}=['Find the power factor as seen from the voltage source (leading or lagging).'];
c=4;enunciados{c}=['Find the reactive power supplied by the voltage source, in VAr.'];
identenunciados=cell(size(enunciados)); scoreexact=zeros(size(enunciados));

c=1;identenunciados{c}=[nomearqm '-a-I1'];scoreexact(c)=2;scoreapprox(c)=1.5;
c=2;identenunciados{c}=[nomearqm '-b-pfRL'];scoreexact(c)=2;scoreapprox(c)=1.5;
c=3;identenunciados{c}=[nomearqm '-c-pfSource'];scoreexact(c)=3;scoreapprox(c)=2;
c=4;identenunciados{c}=[nomearqm '-b-Qs'];scoreexact(c)=3;scoreapprox(c)=2;

saida=[];

for c=1:size(entrada,1)
    for c2=1:size(entrada,2)
        if ~isempty(str2num(entrada{c,c2}))
        instr=[label_entrada{c2},' = str2num(entrada{c,c2});'];
        else instr=[label_entrada{c2},' = entrada{c,c2};'];
        end
        eval(instr);
    end
   
        %correct answers calculation
        
        %capacitor current phasor, assuming phase angle in source voltage
        %equal to zero
        ITwoPhasor=j*ITwo; %90 degrees lead
        
        %resistor ohm value based on active power and voltage
        R=PThree/IThree^2;
        
        %inductive reactance of RL branch
        XL=sqrt((V/IThree)^2-R^2);
        
        %current phasor in RL branch
        IThreePhasor=V/(R+j*XL);
        
        %current in voltage source
        IOnePhasor=ITwoPhasor+IThreePhasor;
        IOne=abs(IOnePhasor);
        
        %power factor in RL branch
        pfRL=cos(angle(IThreePhasor));
        
        %power factor in source
        pfSource=cos(angle(IOnePhasor));
        
        %reactive power in source
        Qcap=-V*ITwo;
        QRL=XL*IThree^2;
        QSource=Qcap+QRL;
 
        %select the answers for all questions
        saida=[saida; IOne,pfRL,pfSource,QSource];

end

%if the students should get different questions, the following matrix should have more than one line

%the numbers in 'v_perguntas' correspond to the position of numeric answers in 'saida' matrix.
v_perguntas=[1 2 3
             1 2 4];
%essa vari�vel pode ter mais de uma linha, para o caso de serem variados os enunciados (n�o apenas os valores).
% essa vers�o do programa ainda n�o faz a varredura determin�stica das op��es de quest�es

%% Se��o para abrigar o tex de outros tipos de quest�es n�o num�ricas (abertas, V/F)
% O c�digo tex dessas questoes dever� ser definido em cell matrices, e ser�o
% chamados na se��o a seguir

%open answer questions should be declared in cell matrices using the name 'open_1', 'open_2', ...
    if is_octave() %if Octave
        pontuacao=char([34 34]); %double quotes
      else %if Matlab
        pontuacao=char([39 39]); %single quotes
    end


%the possible scores for each open question are calculated here. The result must be in the form of consecutive \wrongchoice and \correctchoice declarations
% these lines should be repeated for each open questions
scoreopen='';
totalquestionscore=3.0;
scorestep=0.5;
passos_num=strread(num2str(0:scorestep:totalquestionscore),'%s')';%{'0.0' '0.2' '0.4' '0.6' '0.8' '1.0'} ;
for c=1:(size(passos_num,2)-1)
   scoreopen=[scoreopen,'\wrongchoice[\tiny ' passos_num{c} ']{\tiny '  passos_num{c} '}\scoring{' passos_num{c} '}'];
end
scoreopen=[scoreopen,'\correctchoice[\tiny ' passos_num{end} ']{\tiny '  passos_num{end} '}\scoring{' passos_num{end} '}'];

open_1={'% Open question'
    ['\begin{question}{open-',nomearqm, '}',...%Here goes the text for the open question
    'Describe the procedure and assumptions that should be followed to find the capacitor that adjusts the power factor to a specific value.']
    ' '
    ['~\AMCOpen{lines=5, dots=false, framerule=0pt}{']};
open_1=[open_1;[scoreopen,'}']];
open_1=[open_1;'\end{question}'];

%indica se as quest�es estar�o ou n�o agrupadas em colunas. 
layout_perguntas={
    '1';
    '2';
    '3';
    'open_1';
    };
%Se houver varia��es de enunciados (n�o apenas de valores) de uma prova
%para outra, os n�meros da vari�vel layout_perguntas se referem aos
%elementos de cada linha de v_perguntas

%o vetor v_perguntas deve ser a mesma quantidade de perguntas do vetor
% letrasrepostas
% para fazer menos perguntas, colocar 0 (zero) nas �ltimas colunas

%varia��o de enunciados de quest�o. Os n�meros se referem � celula
%'enunciados' e 'identenunciados'

%a quantidade de respostas � <= que a quantidade de enunciados
%letrasrespostas={'A','B','C','D'};
letrasrespostas={};
for cont=1:size(v_perguntas,2)
    letrasrespostas=[letrasrespostas, ['' char(64+cont) '']];
end


%% Configura��es default e exce��es para n�mero de d�gitos, decimais, toler�ncia e sinal
valorresposta=zeros(1,length(enunciados));
digitsminimo=zeros(1,length(enunciados)); %n�mero de d�gitos m�nimo. Ser� escrito, no csv, o maior entre esse valor e o calculado pelas varia��es de par�metro de entrada
decimalsresposta=zeros(1,length(enunciados));
margemresposta=margemgeral*ones(1,length(enunciados)); %tolerancia padr�o, pode ser alterada caso a caso
faixaexatoresposta=faixaexatogeral*ones(1,length(enunciados)); %tolerancia padr�o = , pode ser alterada caso a caso

sinal=cell(1,length(enunciados));
for c=1:length(sinal)
    sinal{c}='true';  %por padr�o, todas as respostas t�m sinal, pode ser alterada caso a caso
end
toleranciaultimodigito=cell(1,length(enunciados));
for c=1:length(sinal)
    toleranciaultimodigito{c}=toleranciaultimodigitogeral;  %por padr�o, � usada a faixaexatogeral
end

% Exce��es
%De acordo com os �ndice dos enunciados, � poss�vel especificar o numero m�nimo de
%d�gitos (contando com os d�gitos ap�s a v�rgula), n�mero de decimais, se a
%resposta tem ou n�o sinal, e se haver� toler�ncia no �ltimo d�gito
c=1; digitsminimo(c)=4; decimalsresposta(c)=2; sinal{c}='false'; toleranciaultimodigito{c}='true';
c=2; digitsminimo(c)=3; decimalsresposta(c)=2; sinal{c}='false'; toleranciaultimodigito{c}='true';
c=3; digitsminimo(c)=3; decimalsresposta(c)=2; sinal{c}='false'; toleranciaultimodigito{c}='true';
c=4; digitsminimo(c)=5; decimalsresposta(c)=2; sinal{c}='false'; toleranciaultimodigito{c}='true';

% a variavel layout_questoes � somente a convers�o de layout_perguntas da seguinte forma 1->A, 2->B,...

layout_questoes=layout_perguntas;
for c1=1:size(layout_perguntas,1)
    for c2=1:size(layout_perguntas,2)
        if ~isempty(str2num(layout_perguntas{c1,c2}))
            layout_questoes{c1,c2}=char(64+str2num(layout_perguntas{c1,c2}));
        end
    end
end


%coloca aspas duplas nos enunciados das quest�es, para evitar problemas no
%csv se houver v�rgulas dentro do texto
for i=1:size(enunciados,1)
    enunciados{i}=['"' enunciados{i} '"'];
end


%% Cria��o da matriz de entrada dos dados
% � poss�vel criar a matriz manualmente, caso desejado
         %'A','B', 'C',  'D',  'E', 'F', 'G', 'H'


% for c1=v_V_Z
    %      for c2=v_ZL
    %         for c3=v_ZL
    %             for c4=v_VcargaL
    % O FORMATO ABAIXO � IMPORTANTE PARA A
    % INTERA��O COM O USU�RIO
    % (ver pr�xima se��o)
    formato_entrada=strjoin(label_entrada,',');
    %Roda o equivalente � linha comentada seguinte
    %entrada=[entrada;{c1{1},c1{2}];
    %feito dessa forma para ser usado como exemplo, no caso de
    %introdu��o dos valores no prompt de comando
%     codigoentrada=['entrada=[entrada;{ ' formato_entrada '}];'];
%     eval(codigoentrada);
    %             end
    %         end
    %      end
% end


% a cell array 'entrada' pode ser constru�da manualmente, se desejado
% entrada={
%     '127' '100' '6.0' '0.92'
%     '127' '100' '10.0' '0.92'
%     }  ;
%% Intera��o com o usu�rio. Dificilmente ser� necess�rio editar
%  O usu�rio escolhe:
%  1. Se vai escrever os arquivos tex e csv (pode ser "n�o" caso esteja
%     fazendo altera��es no problema
%  2. Se vai utilizar os valores de entrada estabelecidos no arquivo .m.
%     (pode ser "n�o" caso se deseje testar um conjunto de valores espec�fico
%  3. Se vai realizar um backup do arquivo csv existente

%#### Entrada do usu�rio ###################
escreve_csvtex=true;
resp_prompt1=input(['Generate .csv and .tex files? (Y=file output, N=prompt output), default=Y',char(10)],'s');
if max(strcmp(resp_prompt1,{'n','N','0'}))==1
    escreve_csvtex=false;
end

utiliza_entrada_m=true;
if escreve_csvtex==false %s� pode escrever valores espec�ficos de entrada se n�o for escrever nos arquivos .csv e .tex
    resp_prompt2=input(['Use input data as written in m. file (Y/N)? (To introduce a line with a specific set of values, type ''N''), default=Y',char(10)],'s');
    if max(strcmp(resp_prompt2,{'n','N','0'}))==1
        utiliza_entrada_m=false;
    end
end

if utiliza_entrada_m==false
    %     primlinhaentrada=char(entrada(1,:));
    %     stringexemplo='';
    %     for c=1:size(primlinhaentrada,1)
    %         stringexemplo=[stringexemplo ['''' strtrim(primlinhaentrada(c,:)) ''' ']];
    %     end
    entradaexemplo=entrada(1,:);
    stringexemplo= strjoin(entrada(1,:),',');
    %char(10)=line feed character
    resp_prompt3=input(['Introduce the input data, separated by comma, as they should be written in .csv file.',char(10), formato_entrada ,char(10),'(Example:' stringexemplo,')'...
        char(10),'Hint: you can copy a specific line from ''entrada'' variable. Run this .m script, answer ''Y'' and ''N'' for the first and second questions, ''Enter'' for the others, '...
        'and after the end of eclexecution, ask for ''entrada'' variable.',char(10) ...
        'Run the following command: strjoin(entrada(<intended_line>,:),'',''), and copy the result to the clipboard.',char(10)],'s');
    %entrada=strsplit(strrep(resp_prompt3,'''',''));
    %      entrada=strrep(resp_prompt3,''',''',',');
    %      entrada=strrep(entrada,'''','');
    entrada=regexprep(resp_prompt3,'\s+', ' '); %remove excesso de espa�os
    entrada=strrep(entrada,', ,',',,'); %elimina espa�os entre v�rgulas, se houver
    entrada=strrep(entrada,' ',','); %caso a entrada tenha sido separada por espa�os, n�o recomendado, trocar por v�rgulas (essa forma de entrada n�o funciona para strings nulas, obviamente...)
    entrada=strrep(entrada,',,',',auxNulo,'); %substitui temporariamente a string nula ('') pelo texto 'auxNulo', para possibilitar o uso do strsplit
    entrada=strsplit(entrada,{',',' '});
    auxNulo=strcmp(entrada,'auxNulo'); %destroca a string auxNulo pela string vazia
    entrada(auxNulo)={''};

    %Check if the input data is consistent: has the same number and classes of original 'entrada'
    entradaok=true
    if size(entradaexemplo,2)==size(entrada,2)
      for c=1:size(entradaexemplo,2)
        if ~strcmp(class(entradaexemplo(c)),class(entrada(c)))
          entradaok=false
        end
      end
    else
      entradaok=false
    end
    if entradaok==false
      display(['Inconsistent input data; using first line of original input instead.',char(10)]);
      entrada=entradaexemplo;
    end
end

mostrarespostas=false;
%a decis�o � invertida nesse caso
if escreve_csvtex==true
    resp_prompt4=input(['LateX file without printed answers (Y/N)?(*** Attention Y=WITHOUT printed answers, N=WITH printed answers ***), default=Y',char(10)],'s');
    if max(strcmp(resp_prompt4,{'n','N','0'}))==1
        mostrarespostas=true;
    end
end

arquivobkp=false;
if escreve_csvtex==true
    resp_prompt5=input(['Backup of existing file, with time/date tag (Y/N)?, default=N',char(10)],'s');
    if max(strcmp(resp_prompt5,{'s','S','y','Y','1'}))==1
        arquivobkp=true;
    end
end

sorteio=false;
resp_prompt6=input(['Random order of lines in .csv file? (Attention: if N is chosen, last variations may never be used!, default=N)',char(10)],'s');
if max(strcmp(resp_prompt6,{'s','S','y','Y','1'}))==1
    sorteio=false;
end

resposta_tex={};
for c=1:length(letrasrespostas)
    if mostrarespostas==true
        resposta_tex=[resposta_tex,['\Resposta' letrasrespostas{c}]];
        %Cria algo como '\RespostaA','\RespostaB','\RespostaC' para imprimir as respostas nos exemplares
    else
        resposta_tex=[resposta_tex,' '];
    end
end

%#### Fim da Entrada do usuário ###################

%% Escreve o cabe�alho do arquivo .csv
este_arq=mfilename('fullpath');
%se a vari�vel 'escreve_csvtex' for 'false', o resultado ser� exibido na linha de
%comando
%isso � perguntado no prompt do usu�rio

%se desejado (arquivobkp==1, solicitado no prompt do usu�rio), faz o bkp do
%arquivo .csv existente

if escreve_csvtex==true
    if (arquivobkp==1 && exist([este_arq '.csv'], 'file')>0)
        FileInfo = dir([este_arq '.csv']);
        datahoraantigo=strrep(FileInfo.date,':','-');
        movefile([este_arq '.csv'],[este_arq '-bkp-' datahoraantigo '.csv'])
    end
    if is_octave() %if Octave
      fid = fopen([este_arq '.csv'],'w');
      else %if Matlab
        fid = fopen([este_arq '.csv'],'wt','n','UTF-8');
    end
else fid=1;
end
% Cabe�alho
for c=1:length(label_entrada)
    fprintf(fid,[label_entrada{c} ', ']);
    %imprime algo como 'ComponenteA, ComponenteB, ComponenteC,'
end

for c=1:length(letrasrespostas)
    fprintf(fid,['idEnunciado' letrasrespostas{c} ', Enunciado' letrasrespostas{c} ...
        ', Resposta' letrasrespostas{c} ', DigitsResposta' letrasrespostas{c} ...
        ', DecimalsResposta' letrasrespostas{c} ', FaixaExatoResposta' letrasrespostas{c} ', MargemResposta' letrasrespostas{c} ',']);
    %Imprime algo como 'idEnunciadoA, EnunciadoA, RespostaA, DigitsRespostaA, DecimalsRespostaA, TolRespostaA, '...
end
fprintf(fid,'\n');

for c=1:length(enunciados)
    if decimalsresposta(c)>0
        digitsresposta(c)=length(num2str(max(abs(saida(:,c))),...
            ['%1.' num2str(decimalsresposta(c)) 'f']))-1;
    else digitsresposta(c)=length(num2str(max(abs(saida(:,(c)))),['%1.0f']));
    end
end

%% Escreve os dados no arquivo csv. Aten��o: a defini��o dos valores de componentes de entrada no csv deve ser feita manualmente
%  Para limitar o n�mero de linhas do csv, sorteia, sem reposi��o, o n�mero de linhas definido no in�cio do programa
jasorteados=[0 0];

i=1;
%in the case of there are less input data variations then the specified in 'lines' variable

if (sorteiocomrepeticao==false || sorteio==false)
    lines=min(lines,size(entrada,1)*size(v_perguntas,1));
end

while i<=lines
    
    %if 'sorteio' (random choose) is true, input data and questions are chosen using rand function
    if sorteio==true
        sorteioent=ceil(rand(1)*size(entrada,1));
        sorteioquest=ceil(rand(1)*size(v_perguntas,1));
    else
     %if 'sorteio' (random choose) is false, input data and questions are chosen using fix and mod
        sorteioent=fix((i-1)/size(v_perguntas,1))+1;
        sorteioquest=mod(i-1,size(v_perguntas,1))+1;
    end
    
    
    if size(find(jasorteados(:,1)==sorteioent & jasorteados(:,2)==sorteioquest),1)==0
        if sorteiocomrepeticao==false
            if jasorteados(1,1)==0 && jasorteados(1,2)==0
              jasorteados=[];
            end
            jasorteados=[jasorteados;sorteioent sorteioquest];
        end
        
        %         %neste caso espec�fico, escrever no csv o valor complexo
        %         complexo=str2num(entrada{sorteioent,1})+j*str2num(entrada{sorteioent,2});
        
        %formato_entrada=PotGerP(MVA), V(kV), z0P,         z1P,         PotGerQ(MVA), z0Q,         z1Q,          Z0PQ,   Z1PQ,  Z1QR
%         componenteA=entrada{sorteioent,1};
%         componenteB=entrada{sorteioent,2};
%         componenteC=entrada{sorteioent,3};
%         %         componenteI=num2str(saida(sorteioent,1),'%1.0f');
        %         componenteC=entrada{sorteioent,3};
        %         componenteC=['${',strrep(componenteC,'*','\cdot'),'}$'];
        %         componenteD=entrada{sorteioent,4};
        
        
        
        for c=1:length(label_entrada)
            %se alguma entrada for um n�mero complexo, substitui o
            %asterisco por ponto
            txt_entrada=entrada{sorteioent,c};
            if ~isempty(str2num(txt_entrada)) && imag(str2num(txt_entrada))~=0
                txt_entrada=['$',strrep(txt_entrada,'*','\cdot'),'$'];
            end
%                         aux_cmd=[label_entrada{c},' = txt_entrada;'];
%                         eval(aux_cmd);
            aux_cmd=['fprintf(fid,''%s,'', txt_entrada);'];
            eval(aux_cmd);
        end
        %         fprintf(fid,'%s,', entrada{sorteioent,1});
        %         fprintf(fid,'%s,', entrada{sorteioent,2});
        %         fprintf(fid,'%s,', entrada{sorteioent,3});
        %         fprintf(fid,'%s,', entrada{sorteioent,4});
        %         fprintf(fid,',');
        %         fprintf(fid,',');
        
        for c2=1:size(v_perguntas,2)
            if v_perguntas(sorteioquest,c2)>0
                enunciados_now=enunciados{v_perguntas(sorteioquest,c2)};
                identenunciados_now=identenunciados{v_perguntas(sorteioquest,c2)};
                decimalsresposta_now=decimalsresposta(v_perguntas(sorteioquest,c2));
                faixaexatoresposta_now=faixaexatoresposta(v_perguntas(sorteioquest,c2));
                margemresposta_now=margemresposta(v_perguntas(sorteioquest,c2));
                digitsresposta_now=max(digitsresposta(v_perguntas(sorteioquest,c2)),digitsminimo(v_perguntas(sorteioquest,c2)));
                valorresposta_now=saida(sorteioent,(v_perguntas(sorteioquest,c2)));
                fprintf(fid,['%s,%s,%1.' num2str(decimalsresposta_now) 'f,%1.0f,%1.0f,%1.' num2str(decimalsresposta_now) 'f,%1.' num2str(decimalsresposta_now) 'f,'],...
                    identenunciados_now, enunciados_now, valorresposta_now, digitsresposta_now, decimalsresposta_now, faixaexatoresposta_now*valorresposta_now, margemresposta_now*valorresposta_now);
            else
                fprintf(fid,[',vazio,0,0,0,0,']);
            end
        end
        fprintf(fid,'\n');
        i=i+1;
    end
end

%se a sa�da do programa foi para a linha de comando, n�o pode dar o fclose
if escreve_csvtex==true
    fclose(fid);
end

%% Come�a a escrever o arquivo tex

este_arq=mfilename('fullpath');
[este_arq_path,este_arq_name,este_arq_ext]=fileparts(este_arq);
%em caso de rodar esse programa para teste, sem gerar os arquivos, setar a
%vari�vel escreve_csvtex para 'false'; o resultado ser� exibido na linha de
%comando
  if escreve_csvtex==true
        if is_octave() %if Octave
        fid = fopen([este_arq '.tex'],'w');
        else %if Matlab
          fid = fopen([este_arq '.tex'],'wt','n','UTF-8');
  end
else fid=1;
end
nomebase=strrep(este_arq_name,'_','');


%conte�do do .tex at� antes do enunciado do problema
cont_latex_inicio={
    ['\def\nomebase{' nomebase '}']
    ['\DTLifdbexists{\nomebase}{}{\DTLloaddb{\nomebase}{' este_arq_name '.csv}}']
    ''
    '\makeatletter'
    '\@ifundefined{contagem\nomebase}{%'
    '\def\contagem\nomebase{\DTLrowcount{\nomebase}}'
    '}{}'
    '\makeatother'
    ' '
    '\makeatletter'
    '\def\numprova{\the\AMCid@etud}'
    '\makeatother'
    ' '
    '%####Descomentar linha a seguir para buscar as linhas do csv de forma sequencial, de acordo com o n�mero da prova'
    '\FPeval\numlinha{round(\numprova-(\contagem\nomebase)*trunc((\numprova-1)/(\contagem\nomebase),0),0)}'
    ' '
    '%####Descomentar linha a seguir para buscar as linhas no csv de forma aleatoria'
    '%\FPeval\numlinha{round(1+random*(\contagem\nomebase -1),0)}'
    ' '
    };

%% Trecho do tex que l� os dados de entrada

% primeiras colunas cont�m os dados de entrada
cont_latex_componentes={};
for c=1:length(label_entrada)
    cont_latex_componentes=[cont_latex_componentes;['\DTLgetvalue{\' label_entrada{c} '}{\nomebase}{\numlinha}{' num2str(c) '}']];
    %escreve linhas como '\DTLgetvalue{\ComponenteA}{\nomebase}{\Circuito}{1}'
end

colunacsvatual=length(label_entrada);
cont_latex_componentes=[cont_latex_componentes;' '];

for c=1:length(letrasrespostas)
    cont_latex_componentes=[cont_latex_componentes;['\DTLgetvalue{\idEnunciado'         letrasrespostas{c} '}{\nomebase}{\numlinha}{' num2str(colunacsvatual+7*(c-1)+1) '}']];
    cont_latex_componentes=[cont_latex_componentes;['\DTLgetvalue{\Enunciado'           letrasrespostas{c} '}{\nomebase}{\numlinha}{' num2str(colunacsvatual+7*(c-1)+2) '}']];
    cont_latex_componentes=[cont_latex_componentes;['\DTLgetvalue{\Resposta'            letrasrespostas{c} '}{\nomebase}{\numlinha}{' num2str(colunacsvatual+7*(c-1)+3) '}']];
    cont_latex_componentes=[cont_latex_componentes;['\DTLgetvalue{\DigitsResposta'      letrasrespostas{c} '}{\nomebase}{\numlinha}{' num2str(colunacsvatual+7*(c-1)+4) '}']];
    cont_latex_componentes=[cont_latex_componentes;['\DTLgetvalue{\DecimalsResposta'    letrasrespostas{c} '}{\nomebase}{\numlinha}{' num2str(colunacsvatual+7*(c-1)+5) '}']];
    cont_latex_componentes=[cont_latex_componentes;['\DTLgetvalue{\FaixaExatoResposta'         letrasrespostas{c} '}{\nomebase}{\numlinha}{' num2str(colunacsvatual+7*(c-1)+6) '}']];
    cont_latex_componentes=[cont_latex_componentes;['\DTLgetvalue{\MargemResposta'         letrasrespostas{c} '}{\nomebase}{\numlinha}{' num2str(colunacsvatual+7*(c-1)+7) '}']];
    cont_latex_componentes=[cont_latex_componentes;[' ']];
    %escreve linhas como  '\DTLgetvalue{\idEnunciadoA}{\nomebase}{\Circuito}{7}'
    % '\DTLgetvalue{\EnunciadoA}{\nomebase}{\Circuito}{8}'
    % '\DTLgetvalue{\RespostaA}{\nomebase}{\Circuito}{9}'
    % '\DTLgetvalue{\DigitsRespostaA}{\nomebase}{\Circuito}{10}'
    % '\DTLgetvalue{\DecimalsRespostaA}{\nomebase}{\Circuito}{11}'
    % '\DTLgetvalue{\TolRespostaA}{\nomebase}{\Circuito}{12}'
end

for c=1:length(letrasrespostas)
    cont_latex_componentes=[cont_latex_componentes;['\ifthenelse{\equal{\Enunciado' letrasrespostas{c} '}{vazio}}{}{\FPeval\FaixaExato' letrasrespostas{c} '{round(abs(\FaixaExatoResposta' letrasrespostas{c} ')*10^\DecimalsResposta' letrasrespostas{c} ',0)}}']];
    % escreve algo como '\ifthenelse{\equal{\EnunciadoA}{vazio}}{}{\FPeval\ToleranciaA{round(abs(\TolRespostaA)*10^\DecimalsRespostaA,0)}}'
end
cont_latex_componentes=[cont_latex_componentes;' '];

for c=1:length(letrasrespostas)
    cont_latex_componentes=[cont_latex_componentes;['\ifthenelse{\equal{\Enunciado' letrasrespostas{c} '}{vazio}}{}{\FPeval\Margem' letrasrespostas{c} '{round(abs(\MargemResposta' letrasrespostas{c} ')*10^\DecimalsResposta' letrasrespostas{c} ',0)}}']];
    % escreve algo como '\ifthenelse{\equal{\EnunciadoA}{vazio}}{}{\FPeval\ToleranciaA{round(abs(\TolRespostaA)*10^\DecimalsRespostaA,0)}}'
end
cont_latex_componentes=[cont_latex_componentes;' '];

%trecho ap�s o enunciado do problema, com a montagem AMC das quest�es
cont_latex_questoes={};
layout_questoes_linhas=size(layout_questoes,1);
layout_questoes_colunas=size(layout_questoes,2);

for c=1:layout_questoes_linhas
    numstrings=layout_questoes_colunas-sum(cellfun('isempty',layout_questoes(c,:)));  %calcula o numero de strings n�o nulas na linha
    if numstrings>1 %se houver necessidade de fazer multicols
        cont_latex_questoes=[cont_latex_questoes;' '];
        cont_latex_questoes=[cont_latex_questoes;['\begin{multicols}{',num2str(numstrings),'}']];
        cont_latex_questoes=[cont_latex_questoes;' '];
    end
    %verifica quais strings n�o s�o nulas e executa a itera��o
    naonulas=find(cellfun('isempty',layout_questoes(c,:))==0);
    for c2=naonulas
        stringnow=layout_questoes{c,c2};
        tiponumerica=find(strcmp(letrasrespostas,stringnow)==1); %verifica se a quest�o � num�rica, listada no vetor letrasrespostas
        if ~isempty(tiponumerica) %se a busca no vetor letrasresposta n�o retornou uma matriz nula, ou seja, se a string atual pertence ao conjunto de letra associado a quest�es num�ricas
            letraresposta=letrasrespostas{tiponumerica};
            %Verifica se a quest�o atual deve ter considerada exata dentro
            %da faixa definida ou +- o �ltimo d�gito
            if strcmp(toleranciaultimodigito{tiponumerica},'true')
                txt_exato=',exact=1';
            else
                txt_exato=[',exact=\FaixaExato',letraresposta];
            end
            questaotmp={['\ifthenelse{\equal{\Enunciado',letraresposta,'}{vazio}}{}{'];
                '\vspace{1cm}';
                ['\begin{questionmultx}{q ',letraresposta,'\idEnunciado',letraresposta,'}'];
                % ['\Enunciado',letraresposta,' \\ (toler�ncia: $\pm~',num2str(fatortolresposta(tiponumerica)*100,'%0.1f') '~\%$)'];
                ['\Enunciado',letraresposta];
                ['\AMCnumericChoices{\Resposta',letraresposta,'{}}{digits=\DigitsResposta',letraresposta,','...
                'decimals=\DecimalsResposta',letraresposta,',sign=',sinal{tiponumerica}, ...
                ',borderwidth=1pt,approx=\Margem',letraresposta,txt_exato,',vertical=true,hspace=0.3em,vspace=0.5ex,'...
                'scoreexact=',num2str(scoreexact(tiponumerica)),',scoreapprox=',num2str(scoreapprox(tiponumerica)),'}'],
                resposta_tex{tiponumerica};
                '\end{questionmultx}}'
                ' '};
            cont_latex_questoes=[cont_latex_questoes;questaotmp];
        end
        %check if string begins with 'open'
        if length(stringnow)>length('open')&& strcmpi(stringnow(1:length('open')),'open')==1
            eval(['cont_latex_questoes=[cont_latex_questoes;',stringnow,'];']);
        end
        if strcmpi(stringnow,'clearpage')==1
            cont_latex_questoes=[cont_latex_questoes;'~\clearpage'];
            cont_latex_questoes=[cont_latex_questoes;' '];
        end
    end
    if numstrings>1 %se houver necessidade de fazer multicols
        cont_latex_questoes=[cont_latex_questoes;'\end{multicols}'];
        cont_latex_questoes=[cont_latex_questoes;' '];
    end
end


cont_latex=[cont_latex_inicio;cont_latex_componentes;enun_problema;cont_latex_questoes];



%% Finaliza escrita do arquivo tex, fecha o arquivo e encerra execu��o

if utiliza_entrada_m==false
    cont_latex={' '};
end

for c=1:(length(cont_latex)-1)
    fprintf(fid,'%s \n',cont_latex{c});
end
%para n�o imprimir uma linha a mais...
fprintf(fid,'%s',cont_latex{length(cont_latex)});

%se a sa�da do programa foi para a linha de comando, n�o pode dar o fclose
if escreve_csvtex==true
    fclose(fid);
    if mostrarespostas==true
        aux='WITH';
    else aux='WITHOUT';
    end
    % desnecess�rio
    %     if arquivobkp==true
    %         copyfile([este_arq '.csv'],[este_arq '_' strrep(datestr(now),':','-') '.csv'])
    %     end
    display([datestr(now) ' ' nomearqm '.m: .csv and .tex files generated ' aux ' printed answers!']);
end
