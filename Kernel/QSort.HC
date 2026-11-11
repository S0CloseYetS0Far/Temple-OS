U0 QSortI64(I64 *base,I64 num, I64 (*fp_compare)(I64 e1,I64 e2))
{/*Quick Sort for width==8.
fp_compare() passes by value instead of ref.

For ascending strings: return StrCmp(e1,e2);
For ascending ints   : return e1-e2;

Maybe, look at $LK,"::/Demo/MultiCore/MPRadix.HC"$.
*/
  I64 i,j,*left,*right,pivot;
  while (num>1) {
    left =base;
    right=base+num-1;
    pivot=base[num/2];
    do {
      while ((*fp_compare)(*left,pivot)<0)
	left++;
      while ((*fp_compare)(*right,pivot)>0)
	right--;
      if (left<=right)
	SwapI64(left++,right--);
    } while (left<=right);
    i=right+1-base;	//Size of left part
    j=base+num-left;	//Size of right part
    if (i>=num || j>=num)
      break;
//Recurse on smaller part, loop on larger: stack depth<=log2(num).
    if (i<j) {
      if (i>1)
	QSortI64(base,i,fp_compare);
      base=left;
      num=j;
    } else {
      if (j>1)
	QSortI64(left,j,fp_compare);
      num=i;
    }
  }
}

U0 QSort2a(U8 **base,I64 num,I64 (*fp_compare)(U8 **_e1,U8 **_e2))
{//Not public.For case of width==size(U8 *)==8.
//fp_compare() passes by ref.
  I64 i,j;
  U8 **left,**right,*pivot;
  while (num>1) {
    left =base;
    right=base+num-1;
    pivot=base[num/2];
    do {
      while ((*fp_compare)(left,&pivot)<0)
	left++;
      while ((*fp_compare)(right,&pivot)>0)
	right--;
      if (left<=right)
	SwapI64(left++,right--);
    } while (left<=right);
    i=right+1-base;	//Size of left part
    j=base+num-left;	//Size of right part
    if (i>=num || j>=num)
      break;
//Recurse on smaller part, loop on larger: stack depth<=log2(num).
    if (i<j) {
      if (i>1)
	QSort2a(base,i,fp_compare);
      base=left;
      num=j;
    } else {
      if (j>1)
	QSort2a(left,j,fp_compare);
      num=i;
    }
  }
}
U0 QSort2b(U8 *base,I64 num, I64 width,
	I64 (*fp_compare)(U8 *e1,U8 *e2),U8 *tmp)
{//Not public
  I64 i,j;
  U8 *left,*right,*pivot=tmp+width;
  while (num>1) {
    left =base;
    right=base+(num-1)*width;
    MemCpy(pivot,base+num/2*width,width);
    do {
      while ((*fp_compare)(left,pivot)<0)
	left+=width;
      while ((*fp_compare)(right,pivot)>0)
	right-=width;
      if (left<=right) {
	if (left!=right) {
	  MemCpy(tmp,right,width);
	  MemCpy(right,left,width);
	  MemCpy(left,tmp,width);
	}
	left+=width;
	right-=width;
      }
    } while (left<=right);
    i=1+(right-base)/width;	//Size of left part
    j=num+(base-left)/width;	//Size of right part
    if (i>=num || j>=num)
      break;
//Recurse on smaller part, loop on larger: stack depth<=log2(num).
    if (i<j) {
      if (i>1)
	QSort2b(base,i,width,fp_compare,tmp);
      base=left;
      num=j;
    } else {
      if (j>1)
	QSort2b(left,j,width,fp_compare,tmp);
      num=i;
    }
  }
}
U0 QSort(U8 *base,I64 num, I64 width, I64 (*fp_compare)(U8 *e1,U8 *e2))
{/*Quick Sort: fp_compare() passes by ref.

For ascending strings: return StrCmp(*e1,*e2);
For ascending ints   : return *e1-*e2;
Don't return e1-e2 if numbers can overflow, return -1,0 or 1.

Maybe, look at $LK,"::/Demo/MultiCore/MPRadix.HC"$.
*/
  U8 *tmp;
  if (width && num>1) {
    if (width==sizeof(U8 *))	//assign instead of MemCpy for width 8
      QSort2a(base,num,fp_compare);
    else {
      tmp=MAlloc(width*2);
      QSort2b(base,num,width,fp_compare,tmp);
      Free(tmp);
    }
  }
}
