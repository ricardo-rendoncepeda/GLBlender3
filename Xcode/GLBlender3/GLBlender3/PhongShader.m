//
//  PhongShader.m
//  GLBlender3
//
//  Created by RRC on 9/9/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import "PhongShader.h"

// Shaders
#define STRINGIFY(A) #A
#include "Phong.vsh"
#include "Phong.fsh"

@implementation PhongShader

- (id)init
{
    if(self = [super init])
    {
        // Program
        self.program = [self BuildProgram:PhongVSH with:PhongFSH];
        
        // Attributes
        self.aPosition = glGetAttribLocation(self.program, "aPosition");
        self.aNormal = glGetAttribLocation(self.program, "aNormal");
        self.aTexel = glGetAttribLocation(self.program, "aTexel");
        
        // Uniforms
        self.uProjectionMatrix = glGetUniformLocation(self.program, "uProjectionMatrix");
        self.uModelViewMatrix = glGetUniformLocation(self.program, "uModelViewMatrix");
        self.uNormalMatrix = glGetUniformLocation(self.program, "uNormalMatrix");
        self.uDiffuse = glGetUniformLocation(self.program, "uDiffuse");
        self.uSpecular = glGetUniformLocation(self.program, "uSpecular");
        self.uTexture = glGetUniformLocation(self.program, "uTexture");
    }
    
    return self;
}

@end
