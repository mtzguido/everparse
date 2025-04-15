#include "krmllib.h"

#include <krml/internal/compat.h>
#include "LParse_TestLib_Aux.h"

FStar_Bytes_bytes LParse_TestLib_SLow_load_file(Prims_string x0)
{
    FStar_Bytes_bytes ret;
    int32_t len;
    LParse_TestLib_Aux_load_file(x0, (uint8_t**)&ret.data, &len);
    ret.length = (uint32_t) len;
    return ret;
}
