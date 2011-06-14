//
//  Shader.vsh
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/14/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

uniform float translate;

void main()
{
    gl_Position = position;
    gl_Position.y += sin(translate) / 2.0;

    colorVarying = color;
}
