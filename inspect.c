#define WASM_EXPORT_AS(name) __attribute__((export_name(name)))
#define WASM_EXPORT(symbol) WASM_EXPORT_AS(#symbol) symbol

#include <malloc.h>
#include "freetype/freetype.h"

FT_Library library;
FT_Face face;

int WASM_EXPORT(render)(unsigned char buffer[], int len, int *ptr, int idx, int size, int *width, int *height)
{
	FT_Init_FreeType(&library);

	FT_New_Memory_Face(library, buffer, len, 0, &face);

	FT_Set_Char_Size(
			face,		 /* handle to face object         */
			0,			 /* char_width in 1/64 of points  */
		  size * 64, /* char_height in 1/64 of points */
			75,			 /* horizontal device resolution  */
			75);		 /* vertical device resolution    */

	FT_Load_Glyph(
			face, /* handle to face object */
			idx,	/* glyph index           */
			0);		/* load flags, see below */

	FT_Render_Glyph(face->glyph,						/* glyph slot  */
									FT_RENDER_MODE_NORMAL); /* render mode */

	// for(int i = 0; i<face->glyph->bitmap.rows; i++){
	// 	for(int j = 0; j<face->glyph->bitmap.pitch; j++){
	// 		out[i * face->glyph->bitmap.pitch + j] = face->glyph->bitmap.buffer[i * face->glyph->bitmap.pitch + j];
	// 	}
	// }

	*ptr = (int)&(face->glyph->bitmap.buffer[0]);

	*width = face->glyph->bitmap.pitch;
	*height = face->glyph->bitmap.rows;

	return (int)&(face->glyph->bitmap.buffer[0]);
	// int sum = 0;
	// for (int i = 0; i < len; i++)
	// {
	// 	sum += a[i];
	// }
	// return sum;
}

void WASM_EXPORT(cleanup)()
{
	FT_Done_Face(face);
	FT_Done_FreeType(library);
	return;
}
