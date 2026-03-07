import 'request_model.dart';

class RequestsDatabase {
  static final List<Request> _requests = [];

  // Add a new request
  static String addRequest(Request request) {
    _requests.add(request);
    return request.id;
  }

  // Get all requests
  static List<Request> getAllRequests() {
    return List.from(_requests);
  }

  // Get requests by user ID
  static List<Request> getRequestsByUserId(String userId) {
    return _requests.where((request) => request.userId == userId).toList();
  }

  // Get request by ID
  static Request? getRequestById(String id) {
    try {
      return _requests.firstWhere((request) => request.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update a request
  static bool updateRequest(Request updatedRequest) {
    try {
      final index = _requests.indexWhere((request) => request.id == updatedRequest.id);
      if (index != -1) {
        _requests[index] = updatedRequest;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete a request
  static bool deleteRequest(String id) {
    try {
      _requests.removeWhere((request) => request.id == id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get requests sorted by date (newest first)
  static List<Request> getRequestsSortedByDate(String userId) {
    final userRequests = getRequestsByUserId(userId);
    userRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userRequests;
  }

  // Get requests by status
  static List<Request> getRequestsByStatus(String userId, String status) {
    return getRequestsByUserId(userId)
        .where((request) => request.status.toLowerCase() == status.toLowerCase())
        .toList();
  }
}