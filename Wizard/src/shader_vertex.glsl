#version 330 core

// Atributos de v�rtice recebidos como entrada ("in") pelo Vertex Shader.
// Veja a fun��o BuildTrianglesAndAddToVirtualScene() em "main.cpp".
layout (location = 0) in vec4 model_coefficients;
layout (location = 1) in vec4 normal_coefficients;
layout (location = 2) in vec2 texture_coefficients;

// Matrizes computadas no c�digo C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

vec3 luz = vec3(1.0,1.0,1.0);

// Atributos de v�rtice que ser�o gerados como sa�da ("out") pelo Vertex Shader.
// ** Estes ser�o interpolados pelo rasterizador! ** gerando, assim, valores
// para cada fragmento, os quais ser�o recebidos como entrada pelo Fragment
// Shader. Veja o arquivo "shader_fragment.glsl".
out vec4 position_world;
out vec4 position_model;
out vec4 normal;
out vec2 texcoords;
out vec3 colorg;

void main()
{
    // A vari�vel gl_Position define a posi��o final de cada v�rtice
    // OBRIGATORIAMENTE em "normalized device coordinates" (NDC), onde cada
    // coeficiente estar� entre -1 e 1 ap�s divis�o por w.
    // Veja {+NDC2+}.
    //
    // O c�digo em "main.cpp" define os v�rtices dos modelos em coordenadas
    // locais de cada modelo (array model_coefficients). Abaixo, utilizamos
    // opera��es de modelagem, defini��o da c�mera, e proje��o, para computar
    // as coordenadas finais em NDC (vari�vel gl_Position). Ap�s a execu��o
    // deste Vertex Shader, a placa de v�deo (GPU) far� a divis�o por W. Veja
    // slides 41-67 e 69-86 do documento Aula_09_Projecoes.pdf.

    gl_Position = projection * view * model * model_coefficients;

    // Como as vari�veis acima  (tipo vec4) s�o vetores com 4 coeficientes,
    // tamb�m � poss�vel acessar e modificar cada coeficiente de maneira
    // independente. Esses s�o indexados pelos nomes x, y, z, e w (nessa
    // ordem, isto �, 'x' � o primeiro coeficiente, 'y' � o segundo, ...):
    //
    //     gl_Position.x = model_coefficients.x;
    //     gl_Position.y = model_coefficients.y;
    //     gl_Position.z = model_coefficients.z;
    //     gl_Position.w = model_coefficients.w;
    //

    // Agora definimos outros atributos dos v�rtices que ser�o interpolados pelo
    // rasterizador para gerar atributos �nicos para cada fragmento gerado.
    // Posi��o do v�rtice atual no sistema de coordenadas global (World).
    position_world = model * model_coefficients;

    // Posi��o do v�rtice atual no sistema de coordenadas local do modelo.
    position_model = model_coefficients;

    // Normal do v�rtice atual no sistema de coordenadas global (World).
    // Veja slides 123-151 do documento Aula_07_Transformacoes_Geometricas_3D.pdf.
    normal = inverse(transpose(model)) * normal_coefficients;
    normal.w = 0.0;

    vec3 Kd = vec3(0.9, 0.9, 0.9);
    vec3 Ka = vec3(0.5,0.5,0.5);
    vec3 Ks = vec3(1.0,1.0,1.0);
    float q = 1.0;
    vec4 origem = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 p = position_world;
    vec4 camera_position = inverse(view) * origem;
    vec4 l = normalize(vec4(1.0,1.0,1.0,0.0));
    vec4 n = normalize(normal);
    vec4 v = normalize(camera_position - p);
    vec4 r = -l+2*n*dot(n,l);


    vec3 I = vec3(0.9,0.9,0.9); //fonte de luz
    vec3 Ia = vec3(0.05,0.05,0.05);  //luz ambiente
    vec3 lambert = Kd*I*max(0, dot(n,l)); //termo difuso de Lambert
    vec3 ambient = Ka*Ia; //ambiente
    vec3 gourad  = Ks*I* pow(max(0,dot(r,v)),q); //termo de gourad

    colorg = lambert + ambient + gourad;

    // Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
    texcoords = texture_coefficients;

}

