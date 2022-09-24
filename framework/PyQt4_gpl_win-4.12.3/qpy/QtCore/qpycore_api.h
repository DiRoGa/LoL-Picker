// This defines the API provided by this library.  It must not be explicitly
// included by the library itself.
//
// Copyright (c) 2018 Riverbank Computing Limited <info@riverbankcomputing.com>
// 
// This file is part of PyQt4.
// 
// This file may be used under the terms of the GNU General Public License
// version 3.0 as published by the Free Software Foundation and appearing in
// the file LICENSE included in the packaging of this file.  Please review the
// following information to ensure the GNU General Public License version 3.0
// requirements will be met: http://www.gnu.org/copyleft/gpl.html.
// 
// If you do not wish to use this file under the terms of the GPL version 3.0
// then you may purchase a commercial license.  For more information contact
// info@riverbankcomputing.com.
// 
// This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
// WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.


#ifndef _QPYCORE_API_H
#define _QPYCORE_API_H


#include <QCoreApplication>
#include <QString>
#include <QVariant>

#include "qpycore_namespace.h"
#include "qpycore_public_api.h"


QT_BEGIN_NAMESPACE
class QAbstractEventDispatcher;
class QObject;
QT_END_NAMESPACE


// Support for pyqtSlot() and pyqtSignature().
PyObject *qpycore_pyqtslot(PyObject *args, PyObject *kwds);
PyObject *qpycore_pyqtsignature(PyObject *args, PyObject *kwds);

// Support for pyqtConfigure().
PyObject *qpycore_pyqtconfigure(PyObject *self, PyObject *args,
        PyObject *kwds);

// Support for the QObject %FinalisationCode.
int qpycore_qobject_finalisation(PyObject *self, QObject *qobj, PyObject *kwds,
        PyObject **updated_kwds);

// Support for converting between PyObject and QString.
PyObject *qpycore_PyObject_FromQString(const QString &qstr);
QString qpycore_PyObject_AsQString(PyObject *obj);
#if !defined(QT_DEPRECATED_SINCE)
#define QT_DEPRECATED_SINCE(m, n)   1
#endif
#if QT_DEPRECATED_SINCE(5, 0)
const char *qpycore_encode(PyObject **s, QCoreApplication::Encoding encoding);
#endif

// Support for converting between PyObject and QStringList.
PyObject *qpycore_PyObject_FromQStringList(const QStringList &qstrlst);
QStringList qpycore_PySequence_AsQStringList(PyObject *obj);
int qpycore_PySequence_Check_QStringList(PyObject *obj);

// Support for converting between PyObject and QVariant.
PyObject *qpycore_PyObject_FromQVariant(const QVariant &qvar);
QVariant qpycore_PyObject_AsQVariant(PyObject *obj, int *is_err);

// Support for Q_CLASSINFO().
PyObject *qpycore_ClassInfo(const char *name, const char *value);

// Support for Q_FLAGS and Q_ENUMS.
PyObject *qpycore_register_int_types(PyObject *type_names);

// Support for creating QGenericArgument and QGenericReturnArgument instances.
PyObject *qpycore_ArgumentFactory(PyObject *type, PyObject *data);
PyObject *qpycore_ReturnFactory(PyObject *type);
PyObject *qpycore_ReturnValue(PyObject *gra);

// Support for QObject.__getattr__().
PyObject *qpycore_qobject_getattr(QObject *qobj, PyObject *py_qobj,
        const char *name);

// Support for QObject.staticMetaObject %GetCode.
PyObject *qpycore_qobject_staticmetaobject(PyObject *type_obj);

// Support for signals/slots.
PyObject *qpycore_qobject_connect(sipErrorState *estate, QObject *qtx,
        PyObject *txObj, PyObject *sigObj, PyObject *rxObj, PyObject *slotObj,
        int type);
PyObject *qpycore_qobject_disconnect(sipErrorState *estate, QObject *qtx,
        PyObject *sigObj, PyObject *rxObj, PyObject *slotObj);
sipErrorState qpycore_qobject_emit(QObject *qtx, PyObject *sigObj,
        PyObject *sigargs);

#if QT_VERSION < 0x050000
// Support for QAbstractEventDispatcher.setEventFilter().
PyObject *qpycore_qabstracteventdispatcher_seteventfilter(
        QAbstractEventDispatcher *disp, PyObject *filter);
#endif

// Support for QMetaObject.connectSlotsByName().
void qpycore_qmetaobject_connectslotsbyname(QObject *qobj,
        PyObject *qobj_wrapper);

// Support for QPyNullVariant.
QVariant *qpycore_qpynullvariant(PyObject *type);

// Support for pyqt[Set]PickleProtocol().
extern PyObject *qpycore_pickle_protocol;

// Support for QObject's garbage collector code.
int qpycore_clearSlotProxies(const QObject *transmitter);
int qpycore_visitSlotProxies(const QObject *transmitter, visitproc visit,
        void *arg);

// Utilities.
#if PY_MAJOR_VERSION >= 3
void qpycore_Unicode_ConcatAndDel(PyObject **string, PyObject *newpart);
#endif

// Initialisation.
void qpycore_init();
void qpycore_post_init(PyObject *module_dict);


#endif
