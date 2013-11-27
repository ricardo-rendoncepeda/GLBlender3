//
//  MainViewController.m
//  GLBlender3
//
//  Created by RRC on 8/28/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import "MainViewController.h"
#import "PhongShader.h"
#import "starship.h"
#import "cube.h"

typedef enum Models
{
    M_CUBE,
    M_STARSHIP,
}
Models;

@interface MainViewController ()
{
    float   _rotate;
    Models  _model;
}

@property (strong, nonatomic) PhongShader* phongShader;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Variables
    _rotate = 0.0f;
    _model = M_CUBE;
    
    // Set up context
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    // Set up view
    GLKView* glkView = (GLKView *) self.view;
    glkView.context = context;
    
    // OpenGL ES Settings
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
    // Load shader
    [self loadShader];
    
    // Load texture
    [self loadTexture];
}

- (void)loadShader
{
    self.phongShader = [[PhongShader alloc] init];
    glUseProgram(self.phongShader.program);
}

- (void)loadTexture
{
    NSDictionary* options = @{GLKTextureLoaderOriginBottomLeft: @YES};
    NSError* error;
    NSString* path;
    switch(_model)
    {
        case M_CUBE:
            path = [[NSBundle mainBundle] pathForResource:@"cube_decal.png" ofType:nil];
            break;
            
        case M_STARSHIP:
            path = [[NSBundle mainBundle] pathForResource:@"starship_decal.png" ofType:nil];
            break;
    }
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    
    if(texture == nil)
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    
    glBindTexture(GL_TEXTURE_2D, texture.name);
    glUniform1i(self.phongShader.uTexture, 0);
}

- (void)setMatrices
{
    // Projection Matrix
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.1f, 10.0f);
    glUniformMatrix4fv(self.phongShader.uProjectionMatrix, 1, 0, projectionMatrix.m);
    
    // ModelView Matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, -2.5f);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(45.0f));
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(_rotate));
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(_rotate));
    switch(_model)
    {
        case M_CUBE:
            modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.5f, 0.5f, 0.5f);
            break;
            
        case M_STARSHIP:
            modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 1.0f, 1.0f, 1.0f);
            break;
    }
    glUniformMatrix4fv(self.phongShader.uModelViewMatrix, 1, 0, modelViewMatrix.m);
    
    // Normal Matrix
    // Transform normals from object-space to eye-space
    bool invertible;
    GLKMatrix3 normalMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(modelViewMatrix, &invertible));
    if(!invertible)
        NSLog(@"MV matrix is not invertible");
    glUniformMatrix3fv(self.phongShader.uNormalMatrix, 1, 0, normalMatrix.m);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Set matrices
    [self setMatrices];
    
    glEnableVertexAttribArray(self.phongShader.aPosition);
    glEnableVertexAttribArray(self.phongShader.aTexel);
    glEnableVertexAttribArray(self.phongShader.aNormal);
    
    // Render model
    switch(_model)
    {
        case M_CUBE:
            [self renderCube];
            break;
            
        case M_STARSHIP:
            [self renderStarship];
            break;
    }
}

- (void)update
{
    _rotate += 1.0f;
}

- (void)renderCube
{
    glVertexAttribPointer(self.phongShader.aPosition, 3, GL_FLOAT, GL_FALSE, 0, cubePositions);
    glVertexAttribPointer(self.phongShader.aTexel, 2, GL_FLOAT, GL_FALSE, 0, cubeTexels);
    glVertexAttribPointer(self.phongShader.aNormal, 3, GL_FLOAT, GL_FALSE, 0, cubeNormals);
    
    for(int i=0; i<cubeMaterials; i++)
    {
        glUniform3f(self.phongShader.uDiffuse, cubeDiffuses[i][0], cubeDiffuses[i][1], cubeDiffuses[i][2]);
        glUniform3f(self.phongShader.uSpecular, cubeSpeculars[i][0], cubeSpeculars[i][1], cubeSpeculars[i][2]);
        
        glDrawArrays(GL_TRIANGLES, cubeFirsts[i], cubeCounts[i]);
    }
}

- (void)renderStarship
{
    glVertexAttribPointer(self.phongShader.aPosition, 3, GL_FLOAT, GL_FALSE, 0, starshipPositions);
    glVertexAttribPointer(self.phongShader.aTexel, 2, GL_FLOAT, GL_FALSE, 0, starshipTexels);
    glVertexAttribPointer(self.phongShader.aNormal, 3, GL_FLOAT, GL_FALSE, 0, starshipNormals);
    
    for(int i=0; i<starshipMaterials; i++)
    {
        glUniform3f(self.phongShader.uDiffuse, starshipDiffuses[i][0], starshipDiffuses[i][1], starshipDiffuses[i][2]);
        glUniform3f(self.phongShader.uSpecular, starshipSpeculars[i][0], starshipSpeculars[i][1], starshipSpeculars[i][2]);
        
        glDrawArrays(GL_TRIANGLES, starshipFirsts[i], starshipCounts[i]);
    }
}

- (IBAction)selectModel:(UISegmentedControl *)sender
{
    self.paused = YES;
    
    int m = (int)sender.selectedSegmentIndex;
    switch(m)
    {
        case 0:
            _model = M_CUBE;
            break;
            
        case 1:
            _model = M_STARSHIP;
            break;
    }
    
    [self loadTexture];
    
    self.paused = NO;
}

@end

