//
//  Shader.fsh
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/14/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
