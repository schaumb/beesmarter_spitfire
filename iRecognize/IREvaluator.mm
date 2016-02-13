//
//  IREvaluator.m
//  iRecognize
//
//  Created by Háló Zsolt on 13/02/16.
//  Copyright © 2016 Spitfire. All rights reserved.
//

#import "IREvaluator.h"

@implementation IREvaluator
	
static const char * const fontTypes[] = {
	"Akiza Sans",
	"Anonymus Pro",
	"Autonym",
	"Averia Sans",
	"Averia Serif",
	"Comic Relief",
	"Courier Code",
	"Coval",
	"Crimson",
	"Cursive Sans",
	"Cursive Serif",
	"Dancing Script",
	"Deja Vu Sans",
	"Deja Vu Serif",
	"Fanwood",
	"Fibel Nord",
	"Free Universal",
	"GFS Artemisia",
	"Katamotz Ikasi",
	"Khmer OS Classic",
	"Liberation Sans",
	"Liberation Serif",
	"Libre Bodoni",
	"Petit Formal Script",
	"Quattrocento",
	"Segoe UI Symbol"
};

const char* evaluate(unsigned char picture[], int sizeX, int sizeY) {
	srand(time(NULL));
	int result = rand() % 26;
	return fontTypes[result];
}

@end
