//
//  Requests.swift
//  HttpUtilityTests
//
//  Created by CodeCat15 on 6/3/20.
//  Copyright © 2020 CodeCat15. All rights reserved.
//

import Foundation

// MARK: - RegisterUserRequest
struct RegisterUserRequest: Encodable
{
    let firstName, lastName, email, password: String

    enum CodingKeys: String, CodingKey {
        case firstName = "First_Name"
        case lastName = "Last_Name"
        case email = "Email"
        case password = "Password"
    }
}

// MARK: - PhoneRequest

struct PhoneRequest: Encodable
{
    let color, manufacturer: String?
}

struct MultiPartFormRequest: Encodable
{
    let name, lastName, dateOfJoining, dateOfBirth, gender, departmentName, managerName: String

    enum CodingKeys: String, CodingKey {

        case name = "Name"
        case lastName = "LastName"
        case dateOfJoining = "DateOfJoining"
        case dateOfBirth = "DateOfBirth"
        case gender = "Gender"
        case departmentName = "DepartmentName"
        case managerName = "ManagerName"
    }
}
