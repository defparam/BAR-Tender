/*++

Module Name:

driver.h

Abstract:

This file contains the driver definitions.

Environment:

User-mode Driver Framework 2

--*/

#include <windows.h>
#include <wdf.h>
#include <initguid.h>

#include "device.h"
#include "queue.h"
#include "trace.h"

#ifndef ASSERT
#if DBG
#define ASSERT( exp ) \
    ((!(exp)) ? \
        (KdPrint(( "\n*** Assertion failed: " #exp "\n\n")), \
         DebugBreak(), \
         FALSE) : \
        TRUE)
#else
#define ASSERT( exp )
#endif // DBG
#endif // ASSERT

EXTERN_C_START

//
// WDFDRIVER Events
//

DRIVER_INITIALIZE DriverEntry;
EVT_WDF_DRIVER_DEVICE_ADD BARTenderEvtDeviceAdd;
EVT_WDF_OBJECT_CONTEXT_CLEANUP BARTenderEvtDriverContextCleanup;

EXTERN_C_END
