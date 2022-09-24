// This is the definition of the various Chimera helpers.
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


#ifndef _QPYDBUSCHIMERAHELPERS_H
#define _QPYDBUSCHIMERAHELPERS_H


#include <Python.h>

#include <QVariant>


// Keep this in sync. with that defined in the Chimera class.
typedef bool (*FromQVariantFn)(const QVariant *, PyObject **);


bool qpydbus_from_qvariant(const QVariant *varp, PyObject **objp);


#endif
