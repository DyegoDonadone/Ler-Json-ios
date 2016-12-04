//
//  ViewController.m
//  LerJson
//
//  Created by Faculdade Alfa on 03/12/16.
//  Copyright (c) 2016 Faculdade Alfa. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize tabela, listaDados, listaImagens;

- (void)viewDidLoad {
    [super viewDidLoad];
    listaImagens = [[NSMutableArray alloc] init];
    
    //chamado o carregarDados em thread
    [self performSelector:@selector(carregarDados) withObject:nil];
}

-(void)carregarDados{
    NSError *erro;
    @try {
        //cria a url com o endereço da API
        NSURL *url = [NSURL URLWithString:@"http://marcosdiasvendramini.com.br/Get/Estereogramas.aspx"];
        
        //carrega os dados retorndos pela url
        NSData *dados = [NSData dataWithContentsOfURL:url];
        
        //serializando os dados do Json para o array listaDados
        listaDados = [NSJSONSerialization JSONObjectWithData:dados options:kNilOptions error:&erro];
    
        for (int cont=0; cont < listaDados.count; cont++) {
            //carregando uma imagem padrao para cada item do json
            [listaImagens addObject:[UIImage imageNamed:@"imagem.png"]];
        }
        
        [tabela reloadData];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listaDados.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //criando uma celula apartir do modelo
    UITableViewCell *celula = [tableView dequeueReusableCellWithIdentifier:@"Celula"];
    
    //se não encontrar o modelo, cria a celula com estilo default
    if (celula == nil)
        celula = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Celula"];
    
    //verifica se existe ou não
    if ([listaDados objectAtIndex:indexPath.row] != nil) {
        NSDictionary *dados = [listaDados objectAtIndex:indexPath.row];
    
        // carregando no titulo, o nome do dicionario de dados
        celula.textLabel.text = [dados objectForKey:@"nome"];
        
        celula.imageView.image = [listaImagens objectAtIndex:indexPath.row];
        
        celula.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        //se existe a imagem e a lista com a imagem padrao
        if (([[dados objectForKey:@"img"] isEqualToString:@""] == false)
            && ([[listaImagens objectAtIndex:indexPath.row] isEqual:[UIImage imageNamed:@"imagem.png"]])) {
            
            //montando url da imagem
            NSString *urlImagem = [NSString stringWithFormat:@"http://www.marcosdiasvendramini.com.br/imgEstereograma/m%@", [dados objectForKey:@"img"]];
            
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            
            //fazend download da imagem
            dispatch_async(downloadQueue, ^{
                
                NSData *dataImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlImagem]];
                
                UIImage *imagem = [UIImage imageWithData:dataImg];
                
                if (imagem){ //verifica se nao está nulo
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //trocando a imagem padrao pela baixada
                        [listaImagens replaceObjectAtIndex:indexPath.row withObject:imagem];
                        
                        //carrega imagem na tabela
                        celula.imageView.image = imagem;
                        celula.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        
                        [celula setNeedsLayout];
                    });
                }
            });
        }
    }
    
    return celula;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
