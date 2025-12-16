import 'package:chantier/model/homme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/simple_entity.dart';
import '../repository/chantier_repository.dart';
import '../ui/common/loading.dart';
import 'entity_add.dart';

class MatManagementScreen extends StatefulWidget {
  final String title;
  final String entityName;

  const MatManagementScreen({
    required this.title,
    required this.entityName,
    super.key,
  });

  @override
  State<MatManagementScreen> createState() => _EntityManagementScreenState();
}

class _EntityManagementScreenState extends State<MatManagementScreen> {
  List<Homme> hommes = [];
  List<Camion> camions = [];
  List<Materiel> matriels = [];
  bool isLoading = true;


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (widget.entityName == 'Matériel') {
          matriels = await ChantierRepository().getMateriel() ?? [];
        }
       else if (widget.entityName == 'Camion') {
          camions = await ChantierRepository().getCamions() ?? [];
        }
        else {
          hommes = await ChantierRepository().getHommes() ?? [];
        }
        setState(() {
          isLoading = false;
        });
      }catch(e){
        setState(() {
          isLoading = false;
        });
        print("exception list chantier $e");
      }
    }
    );


      super.initState();
  }

  void _openAddModal() async {
    final newEntity =  widget.entityName == 'Matériel' ? await showDialog<Materiel>(
      context: context,
      builder: (context) => AddSimpleEntityModal(entityName: widget.entityName),
    ) : widget.entityName == 'Camion'  ?
    await  showDialog<Camion>(
      context: context,
      builder: (context) => AddSimpleEntityModal(entityName: widget.entityName),
    ) : await showDialog<Homme>(
      context: context,
      builder: (context) => AddSimpleEntityModal(entityName: widget.entityName),
    );

    if (newEntity != null) {
      setState(() {
        widget.entityName == 'Matériel' ? matriels.add(newEntity as Materiel) : widget.entityName == 'Camion'  ?
        camions.add(newEntity as Camion) :
        hommes.add(newEntity as Homme);
      });
    }
  }

  void _deleteEntity(int index) {
    setState(() {
      widget.entityName == 'Matériel' ? matriels.removeAt(index) : widget.entityName == 'Camion'  ?
      camions.removeAt(index) :
      hommes.removeAt(index);
    });
  }
  bool isMobile = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.blue.shade700,
                    size: 40,
                  ),
                  onPressed: _openAddModal,
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading ? Loader() :   SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: isMobile  ? MediaQuery.of(context).size.height *0.7 : MediaQuery.of(context).size.height *0.8 ,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.entityName == 'Matériel' ? matriels.length : widget.entityName == 'Camion'  ?
                camions.length :
                hommes.length,
                itemBuilder: (context, index) {
                  final entity = widget.entityName == 'Matériel' ? matriels[index] : widget.entityName == 'Camion'  ?
                  camions[index] :
                  hommes[index] ;
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        entity.nom ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("ID: ${entity.id}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              // TODO: Ouvrir un modal de modification
                            },
                          ),
                          // Icône de suppression
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteEntity(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
