abstract class VoterEvent {}

class SaveVoter extends VoterEvent {
  final Map<String, dynamic> data;

  SaveVoter(this.data);
}

class FetchVoterCount extends VoterEvent {}

class FetchAllVoters extends VoterEvent {}
