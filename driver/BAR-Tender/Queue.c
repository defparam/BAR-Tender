/*++

Module Name:

queue.c

Abstract:

This file contains the queue entry points and callbacks.

Environment:

User-mode Driver Framework 2

--*/

#include "driver.h"
#include "queue.tmh"
#include "MsgInterface.h"

NTSTATUS
BARTenderQueueInitialize(
	_In_ WDFDEVICE Device
)
/*++

Routine Description:

The I/O dispatch callbacks for the frameworks device object
are configured in this function.

A single default I/O Queue is configured for parallel request
processing, and a driver context memory allocation is created
to hold our structure QUEUE_CONTEXT.

Arguments:

Device - Handle to a framework device object.

Return Value:

VOID

--*/
{
	WDFQUEUE queue;
	NTSTATUS status;
	PQUEUE_CONTEXT queueContext;
	WDF_IO_QUEUE_CONFIG queueConfig;
	WDF_OBJECT_ATTRIBUTES queueAttributes;

	//
	// Configure a default queue so that requests that are not
	// configure-fowarded using WdfDeviceConfigureRequestDispatching to goto
	// other queues get dispatched here.
	//
	WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(
		&queueConfig,
		WdfIoQueueDispatchSequential
	);

	queueConfig.EvtIoDeviceControl = BARTenderEvtIoDeviceControl;
	queueConfig.EvtIoStop = BARTenderEvtIoStop;

	WDF_OBJECT_ATTRIBUTES_INIT_CONTEXT_TYPE(&queueAttributes, QUEUE_CONTEXT);



	status = WdfIoQueueCreate(
		Device,
		&queueConfig,
		&queueAttributes,
		&queue
	);

	if (!NT_SUCCESS(status)) {
		return status;
	}

	// Get our Driver Context memory from the returned Queue handle
	queueContext = QueueGetContext(queue);
	queueContext->Device = Device;

	return status;
}


VOID
BARTenderEvtIoDeviceControl(
	_In_ WDFQUEUE Queue,
	_In_ WDFREQUEST Request,
	_In_ size_t OutputBufferLength,
	_In_ size_t InputBufferLength,
	_In_ ULONG IoControlCode
)
/*++
Routine Description:
This event is invoked when the framework receives IRP_MJ_DEVICE_CONTROL request.
Arguments:
Queue -  Handle to the framework queue object that is associated with the
I/O request.
Request - Handle to a framework request object.
OutputBufferLength - Size of the output buffer in bytes
InputBufferLength - Size of the input buffer in bytes
IoControlCode - I/O control code.
Return Value:
VOID
--*/
{

	BAR_TENDER_REQ * reqIn;
	BAR_TENDER_REQ * reqOut;
	size_t reqInsz;
	size_t reqOutsz;

	UNREFERENCED_PARAMETER(OutputBufferLength);
	UNREFERENCED_PARAMETER(InputBufferLength);
	UNREFERENCED_PARAMETER(Queue);

	if (IoControlCode != IOCTL_BAR_TENDER)
	{
		WdfRequestCompleteWithInformation(Request, STATUS_INVALID_PARAMETER, 0); // return invalid parameter if not correct IOCTL
		return;
	}

	WdfRequestRetrieveInputBuffer( // Grab the Input Buffer
		Request,
		sizeof(BAR_TENDER_REQ),
		&reqIn,
		&reqInsz
	);

	WdfRequestRetrieveOutputBuffer( // Grab the Output Buffer
		Request,
		sizeof(BAR_TENDER_REQ),
		&reqOut,
		&reqOutsz
	);

	if ((reqInsz < sizeof(BAR_TENDER_REQ)) || (reqOutsz < sizeof(BAR_TENDER_REQ))) // check to make sure we have enough buffer space
	{ 
		WdfRequestCompleteWithInformation(Request, STATUS_BUFFER_TOO_SMALL, 0);
		return;
	}

	if (ProcessMsg(reqIn, reqOut) != 0)
	{
		WdfRequestCompleteWithInformation(Request, STATUS_INVALID_PARAMETER, 0); // return invalid parameter if msgprocessor returns error
		return;
	}

	WdfRequestCompleteWithInformation(Request, STATUS_SUCCESS, sizeof(BAR_TENDER_REQ)); // otherwise all is good, return success
}

VOID
BARTenderEvtIoStop(
	_In_ WDFQUEUE Queue,
	_In_ WDFREQUEST Request,
	_In_ ULONG ActionFlags
)
/*++
Routine Description:
This event is invoked for a power-managed queue before the device leaves the working state (D0).
Arguments:
Queue -  Handle to the framework queue object that is associated with the
I/O request.
Request - Handle to a framework request object.
ActionFlags - A bitwise OR of one or more WDF_REQUEST_STOP_ACTION_FLAGS-typed flags
that identify the reason that the callback function is being called
and whether the request is cancelable.
Return Value:
VOID
--*/
{
	DbgPrint(
		"%!FUNC! Queue 0x%p, Request 0x%p ActionFlags %d",
		Queue, Request, ActionFlags);

	//
	// In most cases, the EvtIoStop callback function completes, cancels, or postpones
	// further processing of the I/O request.
	//
	// Typically, the driver uses the following rules:
	//
	// - If the driver owns the I/O request, it calls WdfRequestUnmarkCancelable
	//   (if the request is cancelable) and either calls WdfRequestStopAcknowledge
	//   with a Requeue value of TRUE, or it calls WdfRequestComplete with a
	//   completion status value of STATUS_SUCCESS or STATUS_CANCELLED.
	//
	//   Before it can call these methods safely, the driver must make sure that
	//   its implementation of EvtIoStop has exclusive access to the request.
	//
	//   In order to do that, the driver must synchronize access to the request
	//   to prevent other threads from manipulating the request concurrently.
	//   The synchronization method you choose will depend on your driver's design.
	//
	//   For example, if the request is held in a shared context, the EvtIoStop callback
	//   might acquire an internal driver lock, take the request from the shared context,
	//   and then release the lock. At this point, the EvtIoStop callback owns the request
	//   and can safely complete or requeue the request.
	//
	// - If the driver has forwarded the I/O request to an I/O target, it either calls
	//   WdfRequestCancelSentRequest to attempt to cancel the request, or it postpones
	//   further processing of the request and calls WdfRequestStopAcknowledge with
	//   a Requeue value of FALSE.
	//
	// A driver might choose to take no action in EvtIoStop for requests that are
	// guaranteed to complete in a small amount of time.
	//
	// In this case, the framework waits until the specified request is complete
	// before moving the device (or system) to a lower power state or removing the device.
	// Potentially, this inaction can prevent a system from entering its hibernation state
	// or another low system power state. In extreme cases, it can cause the system
	// to crash with bugcheck code 9F.
	//

	return;
}
