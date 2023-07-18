#ifndef _CROS_SERVICE_H_
#define _CROS_SERVICE_H_

#include "qom/cros_node.h"
#include "qom/cros_message.h"
#include "qom/cros_err_codes.h"

/*! \defgroup cros_service cROS TCPROS
 *
 *  Implementation of the TCPROS protocol for service message exchanges
 */

/*! \addtogroup cros_service
 *  @{
 */

struct cRosService
{
  cRosMessage *request;
  cRosMessage *response;
  char* md5sum;
};

typedef struct cRosService cRosService;

cRosService * cRosServiceNew();
cRosErrCodePack cRosServiceInit(cRosService* service);
cRosErrCodePack cRosServiceBuild(cRosService* service, const char* filepath);
void cRosServiceRelease(cRosService* service);
void cRosServiceFree(cRosService* service);

/*! @}*/

#endif
