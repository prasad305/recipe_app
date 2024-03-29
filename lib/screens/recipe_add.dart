import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipe_app/data/food_data.dart';
import 'package:recipe_app/services/state_servies.dart';

import '../components/circle_loader.dart';
import '../components/dropdown_widget.dart';
import '../services/api.dart';
import '../utils/constant.dart';
import '../utils/toast.dart';

class RecipeAdd extends StatefulWidget {
  const RecipeAdd({Key? key}) : super(key: key);

  @override
  _RecipeAddState createState() => _RecipeAddState();
}

class _RecipeAddState extends State<RecipeAdd> {
  List<dynamic> data = []; //ApiPass Body Data Holder
  String SelectedValueHolder = ""; //Dropdown Button Selected Value Holder
  String selectedValue = ""; //Dropdown Button Selected Value Holder
  String selectedIngName = ""; //Dropdown Button Selected Value Holder
  int selectedIngId = 0; //Dropdown Button Selected Value Holder
  String selectedMeasurement = "G"; //Dropdown Button Selected Value Holder
  String selectedAmount = "1"; //Dropdown Button Selected Value Holder
  String selectedNoOfServ = "1"; //Dropdown Button Selected Value Holder
  int selectedId = 0; //Dropdown Button Selected Value Holder

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late Timer t;
  static const blue = Color.fromARGB(255, 0, 23, 147);
  final _formKey = GlobalKey<FormState>();
  TextEditingController _ingAmountCon = TextEditingController();
  TextEditingController _recipeNameCon = TextEditingController();
  TextEditingController _recipeIngCon = TextEditingController();
  List<FoodData> allFilterList = [];
  var ingredients = [];
  var _isDisable = false;

  @override
  void initState() {
    super.initState();

    _recipeIngCon.text = "";
    _ingAmountCon.text = "1";
    ingredients = [];
  }

  void onChanged(String newValue) {
    setState(() {
      selectedMeasurement = newValue;
      selectedValue = selectedValue;
      selectedId = selectedId;
    });

    print('Selected value: $selectedMeasurement');
  }

  Future<List<FoodData>> fetchSuggestions(String query) async {
    allFilterList = [];
    final value = await APIManager().getRequest(
        Constant.domain + "/api/v1/Food?name=${query}&pageNo=1&pageSize=10");
    if (value != null && value['results'] != null) {
      if (value['results'] != 0) {
        for (var item in value['results']) {
          allFilterList.add(FoodData(
              fdcId: item['fdcId'] as int,
              name: item['name'] as String,
              category: item['category']));
        }
        return allFilterList;
      } else {
        return allFilterList;
      }
    }
    return allFilterList;
  }

  addIngObj() {
    _recipeIngCon.text +=
        "${selectedIngName + " " + _ingAmountCon.text}$selectedMeasurement\n";
    // ingredients.
    ingredients.add({
      "fdcId": selectedIngId,
      "addedQty": _ingAmountCon.text,
      "unit": selectedMeasurement
    });
    Navigator.of(context).pop();
  }

  saveRecipe() async {
    setState(() {
      _isDisable = true;
    });
    Timer.run(() {
      CircleLoader.showCustomDialog(context);
    });

    var data = {
      "name": _recipeNameCon.text,
      "description": "none",
      "ingredients": ingredients,
      "userId": "Lakshitha119",
      "servesFor": selectedNoOfServ
    };
    await APIManager()
        .postRequest(Constant.domain + "/api/v1/Recipe", data)
        .then((res) {
      print(res);
      CircleLoader.hideLoader(context);
      setState(() {
        _isDisable = false;
      });
      if (res["isSucess"]) {
        MyToast.showSuccess("Recipe Added");
        Navigator.pop(context,true);
      } else {
        MyToast.showError("Failed to add recipe");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        title: const Row(
          children: [
            SizedBox(
              width: 1,
            ),
            Text(
              "Add Recipe",
              style: TextStyle(
                fontFamily: "Roboto",
                letterSpacing: 1.0,
                fontSize: 18.0,
                color: Color(0xfffeb703),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 23, 147),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //First Selection
                  //Spacer

                  const Text(
                    'Enter Recipe Name',
                    style: TextStyle(fontSize: 16),
                  ),

                  TextField(
                    controller: _recipeNameCon,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 100 * 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [blue, Color.fromARGB(255, 4, 34, 193)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                  builder: (context, setState) {
                                return AlertDialog(
                                  content: Stack(
                                    clipBehavior: Clip.none,
                                    children: <Widget>[
                                      Positioned(
                                        right: -30,
                                        top: -30,
                                        child: InkResponse(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.red,
                                            child: Icon(Icons.close),
                                          ),
                                        ),
                                      ),
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: TypeAheadField<FoodData>(
                                                suggestionsCallback: (value) {
                                                  print(value);
                                                  return fetchSuggestions(
                                                      value);
                                                },
                                                builder: (context, controller,
                                                    focusNode) {
                                                  return TextField(
                                                      controller: controller,
                                                      focusNode: focusNode,
                                                      autofocus: true,
                                                      decoration: const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          labelText:
                                                              'Search For Ingredient'));
                                                },
                                                itemBuilder:
                                                    (context, foodData) {
                                                  return ListTile(
                                                    title: Text(foodData.name),
                                                  );
                                                },
                                                onSelected: (city) {
                                                  setState(() {
                                                    selectedIngName = city.name;
                                                    selectedIngId = city.fdcId;
                                                  });
                                                },
                                              ),
                                            ),
                                            Text(selectedIngName,style: TextStyle(fontWeight: FontWeight.w800),),
                                            Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: DropdownWidget(
                                                onChanged: (val) {
                                                  setState(() {
                                                    selectedAmount = val;
                                                  });
                                                },
                                                title: "Select Amount",
                                                items: const [
                                                  "1",
                                                  "2",
                                                  "3",
                                                  "4",
                                                  "5",
                                                  "6",
                                                  "7"
                                                ],
                                                selectedValue:
                                                selectedAmount,
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                child: DropdownWidget(
                                                  onChanged: (val) {
                                                    setState(() {
                                                      selectedMeasurement = val;
                                                    });
                                                  },
                                                  title: "Select Measurement",
                                                  items: const [
                                                    "G",
                                                    "KG",
                                                    "ML",
                                                    "L",
                                                    "Cup",
                                                    "tbl spoon",
                                                    "t spoon"
                                                  ],
                                                  selectedValue:
                                                      selectedMeasurement,
                                                )),

                                            Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: ElevatedButton(
                                                child: const Text('Add'),
                                                onPressed: () {
                                                  // if (_formKey.currentState!
                                                  //     .validate()) {
                                                  //   _formKey.currentState!
                                                  //       .save();
                                                  // }

                                                  if (selectedIngName != "" &&
                                                      selectedIngId != 0) {
                                                    addIngObj();
                                                  } else {}
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, elevation: 0),
                      child: const Text(
                        'Add Ingredient',
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 18.0,
                          color: Colors.white,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Selected Recipe Ingredient',
                    style: TextStyle(fontSize: 16),
                  ),

                  TextField(
                    enabled: false,
                    controller: _recipeIngCon,
                    maxLines: null, // Set maxLines to null for multiline input
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Select Number of Serving ',
                    style: TextStyle(fontSize: 16),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child:

                  DropdownWidget(
                    onChanged: (val) {
                      setState(() {
                        selectedNoOfServ = val;
                      });
                    },
                    title: "",
                    items: const [
                      "1",
                      "2",
                      "3",
                      "4",
                      "5",
                      "6",
                      "7"
                    ],
                    selectedValue:
                    selectedNoOfServ,
                  ),),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Selected Serving Unit',
                    style: TextStyle(fontSize: 16),
                  ),

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child:DropdownWidget(
                    onChanged: (val) {
                    },
                    title: "",
                    items: const [
                      "G",
                      "KG",
                      "ML",
                      "L",
                      "Cup",
                      "tbl spoon",
                      "t spoon"
                    ],
                    selectedValue:
                    selectedMeasurement,
                  )),
                  const SizedBox(
                    height: 20,
                  ),
                  //Submit Button
                  Container(
                    width: MediaQuery.of(context).size.width / 100 * 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [blue, Color.fromARGB(255, 4, 34, 193)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                        onPressed: _isDisable? null :() {
                        if (_recipeNameCon.text == "") {
                          MyToast.showError("Please enter recipe name");
                          return;
                        }
                        if (ingredients.length == 0) {
                          MyToast.showError("Please add ingredient");
                          return;
                        }

                        saveRecipe();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, elevation: 0),
                      child: const Text(
                        'Analyze Recipe',
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 18.0,
                          color: Colors.white,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
