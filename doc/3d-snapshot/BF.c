

#include "BF.h"

uint64_t
BfValidateDummy(
  uint8_t *Ctxt,
  void
  (*ErrorHandlerFn)(
    EVERPARSE_STRING x0,
    EVERPARSE_STRING x1,
    EVERPARSE_STRING x2,
    uint64_t x3,
    uint8_t *x4,
    uint8_t *x5,
    uint64_t x6
  ),
  uint8_t *Input,
  uint64_t InputLength,
  uint64_t StartPosition
)
{
  /* Validating field emp1 */
  uint64_t positionAfterDummy = StartPosition;
  uint64_t res;
  if (EverParseIsSuccess(positionAfterDummy))
  {
    res = positionAfterDummy;
  }
  else
  {
    ErrorHandlerFn("_dummy",
      "emp1",
      EverParseErrorReasonOfResult(positionAfterDummy),
      EverParseGetValidatorErrorKind(positionAfterDummy),
      Ctxt,
      Input,
      StartPosition);
    res = positionAfterDummy;
  }
  uint64_t positionAfteremp1 = res;
  if (EverParseIsError(positionAfteremp1))
  {
    return positionAfteremp1;
  }
  /* Validating field emp2 */
  uint64_t positionAfterDummy0 = positionAfteremp1;
  if (EverParseIsSuccess(positionAfterDummy0))
  {
    return positionAfterDummy0;
  }
  ErrorHandlerFn("_dummy",
    "emp2",
    EverParseErrorReasonOfResult(positionAfterDummy0),
    EverParseGetValidatorErrorKind(positionAfterDummy0),
    Ctxt,
    Input,
    positionAfteremp1);
  return positionAfterDummy0;
}

