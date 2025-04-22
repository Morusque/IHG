
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

ArrayList<Instruction> instructions = new ArrayList<Instruction>();

String indent = "&nbsp;&nbsp;&nbsp;&nbsp;";
ArrayList<String> txtExport;

Term lastToolTerm = null;

void setup() {
  size(1000, 700);
}

void draw() {
}

void keyPressed() {
  if (keyCode==TAB) {
    String titleIndex = year()+"-"+month()+"-"+day()+" "+hour()+"_"+minute()+"_"+second()+" "+millis();
    save("Suggestion du "+titleIndex+".png");
    saveStrings("Suggestion du "+titleIndex+".html", txtExport.toArray(new String[txtExport.size()]));
  } else {
    background(0xFF);
    fill(0);
    textSize(20);
    instructions.clear();
    int nbInstructions = floor(random(3, 20));
    for (int i=0; i<nbInstructions; i++) instructions.add(new Instruction());
    println("---");
    float currentY = 40;
    txtExport = new ArrayList<String>();
    txtExport.add("<style>@font-face {font-family: OCR; src: url(\"OCRAStd.otf\") format(\"opentype\");}</style>");
    txtExport.add("<div style=\"display: flex; flex-direction: row; width: 1800px; height: 100%;\">");
    txtExport.add("<div style=\"font-family: 'OCR'; font-size: 16px; width: 50%; height: 100%; border: 2px solid black; box-sizing: border-box; padding: 50px; white-space: pre-wrap; overflow-wrap: break-word;\">");
    for (int i=0; i<nbInstructions; i++) {
      text(stripHtml(instructions.get(i).sentence), 20, currentY);
      currentY+=30;
      txtExport.add(instructions.get(i).sentence + "<br/>");
    }
    txtExport.add("</div>");
    txtExport.add("<div style=\"width: 50%; height: 100%; border: 2px solid black; box-sizing: border-box; margin-left: 20px;\"></div>");
    txtExport.add("</div>");
  }
}

class Instruction {
  String sentence = "";
  String shapeName = null;
  int gender = -1;// 1 = la, 2 = le
  int number = -1;// 1 = singulier, 1+ = pluriel
  Instruction() {
    // colors
    HashMap<String, Float> colors = new HashMap<String, Float>();
    // colors.put("rouge", 1.0);
    // colors.put("vert", 1.0);
    // colors.put("bleu", 1.0);
    // colors.put("jaune", 1.0);
    // colors.put("violet", 0.7);
    // colors.put("orange", 0.7);
    // colors.put("gris", 0.7);
    // colors.put("blanc", 0.3);
    colors.put("noir", 3.0);
    // colors.put("multicolore", 0.5);
    // instruction
    HashMap<String, Float> actions = new HashMap<String, Float>();
    if (instructions.size()==0) {
      actions.put("Prenez", 1.0);
    } else {
      if (instructions.get(instructions.size()-1).sentence.length()>=6&&!instructions.get(instructions.size()-1).sentence.substring(0, 6).equals("Prenez")) {
        actions.put("Prenez", 7.0);
      }
      actions.put(indent+"Dessinez", 9.0);
      if (instructions.size()>1) {
        actions.put("Faites une petite pause", 0.2);
        actions.put("Séparez le dessin en "+writtenNumber(floor(random(3)+2), 0), 0.4);
        actions.put("Réfléchissez à la narration", 0.4);
        actions.put("Changez d'outil", 0.4);
        actions.put("Retournez la feuille", 0.4);
        actions.put("Faites pivoter la feuille", 0.4);
        actions.put("Recopiez quelque chose depuis un autre dessin", 0.4);
        actions.put("Enlevez les parties du dessin qui ne vous conviennent pas", 0.3);
        actions.put("Pliez la feuille", 0.2);
        actions.put("Mouillez la feuille", 0.2);
        actions.put("Arrêtez-vous et continuez demain", 0.1);
        actions.put("Échangez votre dessin avec quelqu'un d'autre", 0.4);
        actions.put(indent+"Coloriez "+pickExistingShape("le"), 5.0);
        actions.put(indent+"Coloriez la moitié "+pickExistingShape("du"), 1.0);
        actions.put(indent+"Coloriez une partie "+pickExistingShape("du"), 1.0);
        actions.put(indent+"Coloriez les bords "+pickExistingShape("du"), 1.0);
        actions.put(indent+"Gribouillez "+pickExistingShape("le"), 0.5);
        actions.put(indent+"Entourez "+pickExistingShape("le"), 0.5);
        actions.put(indent+"Camoufflez "+pickExistingShape("le"), 0.5);
        actions.put(indent+"Faites rayonner "+pickExistingShape("le"), 0.5);
        actions.put(indent+"Dégradez "+pickExistingShape("le"), 0.5);
        actions.put(indent+"Mettez en valeur "+pickExistingShape("le"), 0.5);
        actions.put(indent+"Habillez "+pickExistingShape("le"), 0.5);
        actions.put(indent+"Faites dire quelque chose "+pickExistingShape("au"), 0.5);
        actions.put(indent+"Ajoutez une annotation à côté "+pickExistingShape("du"), 0.5);
        actions.put(indent+"Faites pousser quelque chose sur "+pickExistingShape("le"), 0.5);
        actions.put(indent+"Dessinez quelque chose en réponse "+pickExistingShape("au"), 0.5);
        actions.put(indent+"Redessinez "+pickExistingShape("le")+" en plus petit", 0.5);
        actions.put(indent+"Redessinez "+pickExistingShape("le")+" en plus grand", 0.5);
        actions.put(indent+"Donnez "+pickExistingShape("au")+" une impression de mouvement", 0.5);
        actions.put(indent+"Ajoutez de la symétrie", 0.4);
        actions.put(indent+"Rendez le dessin moins symétrique", 0.4);
        actions.put(indent+"Ajoutez un détail triste", 0.4);
        actions.put(indent+"Ajoutez un détail ambigu", 0.4);
        actions.put(indent+"Ajoutez un détail ridicule", 0.4);
        actions.put(indent+"Ajoutez un détail mystérieux", 0.4);
        actions.put(indent+"Ajoutez un détail politique", 0.4);
        actions.put(indent+"Ajoutez l'horizon", 0.4);
        actions.put(indent+"Ajoutez un astre", 0.2);
        actions.put(indent+"Ajoutez des éléments de décor", 0.4);
        actions.put(indent+"Réalisez un applat de couleur à l'endroit approprié", 0.4);
        actions.put(indent+"Demandez à quelqu'un d'autre de retoucher le dessin", 0.4);
        actions.put(indent+"Appropriez-vous le dessin", 0.4);
        actions.put(indent+"Rajoutez quelque chose que vous n'aimez pas", 0.4);
        actions.put(indent+"Rajoutez quelque chose que vous aimez", 0.4);
        actions.put(indent+"Grossissez certains traits", 0.4);
        actions.put(indent+"Ajoutez un détail figuratif", 0.4);
        actions.put(indent+"Continuez comme ça", 0.4);
        actions.put(indent+"Exprimez votre créativité", 0.4);
        actions.put(indent+"Ajoutez un motif répété quelque part", 0.4);
        actions.put(indent+"Dupliquez une partie du dessin", 0.4);
        actions.put(indent+"Censurez une partie du dessin", 0.4);
        actions.put(indent+"Signez", 0.4);
        actions.put(indent+"Écrivez le titre de votre dessin", 0.4);
        actions.put(indent+"Déchirez partiellement la feuille", 0.4);
        actions.put(indent+"Déchaînez-vous", 0.4);
        actions.put(indent+"Comblez les espaces vides", 0.4);
        actions.put(indent+"Ajoutez du contraste", 0.4);
        actions.put(indent+"Retouchez les détails en vous appliquant", 0.4);
        actions.put(indent+"Rajoutez des ombres", 0.4);
        actions.put(indent+"Ajoutez de la lumière", 0.2);
        actions.put(indent+"Donnez du volume", 0.2);
        actions.put(indent+"Décorez les bords de la feuille", 0.2);
        actions.put(indent+"Ajoutez une grille", 0.2);
        actions.put(indent+"Utilisez uniquement des formes géométriques pendant 5 minutes", 0.4);
        actions.put(indent+"Incorporez un élément de la nature dans votre dessin", 0.5);
        actions.put(indent+"Transformez une partie du dessin en une carte ou un plan", 0.3);
        actions.put(indent+"Imaginez que votre dessin est vu à travers un miroir", 0.3);
        actions.put(indent+"Incorporez un élément architectural", 0.4);
        actions.put(indent+"Ajoutez un élément surréaliste", 0.5);
        actions.put(indent+"Incluez un élément qui évoque un souvenir personnel", 0.4);
        actions.put(indent+"Utilisez plus de lignes verticales à partir de maintenant", 0.2);
        actions.put(indent+"Utilisez plus de lignes horizontales à partir de maintenant", 0.2);
        actions.put(indent+"Utilisez une technique de pointillisme pour ajouter des détails", 0.4);
        actions.put(indent+"Choisissez un objet aléatoire autour de vous et intégrez-le dans votre dessin", 0.4);
        actions.put(indent+"Racontez une histoire", 0.4);
        actions.put(indent+"Inventez une créature fantastique et donnez-lui une place dans votre dessin", 0.5);
        actions.put(indent+"Mélangez des éléments abstraits et réalistes", 0.4);
        actions.put(indent+"Trouvez un moyen de connecter visuellement deux parties éloignées de votre dessin", 0.4);
        actions.put(indent+"Quelque chose devra être vu de dessus", 0.4);
        actions.put(indent+"Inventez une machine ou un dispositif et incorporez-le dans votre dessin", 0.5);
        actions.put(indent+"Ajoutez des éléments qui jouent avec la perspective", 0.4);
        actions.put(indent+"Intégrez un symboles", 0.4);
        actions.put(indent+"Créez une partie du dessin en utilisant uniquement des lignes verticales ou horizontales", 0.3);
        actions.put(indent+"Ajoutez des formes organiques", 0.4);
        actions.put(indent+"Incorporez une citation", 0.5);
        actions.put(indent+"Utilisez une gamme de couleurs inspirée par une saison", 0.4);
        actions.put(indent+"Intégrez un élément traditionnel de votre culture", 0.4);
        actions.put(indent+"Dessinez en vous inspirant d'une époque historique", 0.4);
        actions.put(indent+"Incorporez un élément inspiré par l'espace ou l'astronomie", 0.3);
        actions.put(indent+"Utilisez une technique de hachures", 0.4);
        actions.put(indent+"Incorporez un élément lié à l'actualité", 0.3);
        actions.put(indent+"Représentez un élément onirique", 0.3);
        actions.put(indent+"Intégrez un élément qui évoque une émotion forte", 0.3);
        actions.put(indent+"Soyez plus extrême", 0.3);
        actions.put(indent+"Soyez plus minimaliste à partir de maintenant", 0.3);
        actions.put(indent+"Imaginez que votre dessin est une partie d'une plus grande série", 0.4);
        actions.put(indent+"Faites en sorte que plusieurs éléments soient alignés", 0.4);
      }
    }
    String actionType =  pickWeightedRandom(actions);
    sentence += actionType;
    if (actionType.equals("Prenez")) {
      // outil
      HashMap<Term, Float> tools = new HashMap<Term, Float>();
      tools.put(new Term("plusieurs feutres", 2, 20), 0.15);
      // tools.put(new Term("trois feutres", 2, 3), 0.15);
      // tools.put(new Term("un pinceau avec de la peinture", 1, 1), 0.1);
      tools.put(new Term("un <b>gros</b> feutre", 2, 1), 5.0);
      tools.put(new Term("un feutre fin", 2, 1), 5.0);
      // tools.put(new Term("un crayon", 2, 1), 1.0);
      // tools.put(new Term("une craie", 1, 1), 0.5);
      tools.put(new Term("l'outil de votre choix", 2, 1), 0.5);
      // tools.put(new Term("des ciseaux", 2, 2), 0.1);
      // tools.put(new Term("un compas", 2, 1), 0.1);
      // tools.put(new Term("un outil inhabituel", 2, 1), 0.05);
      Iterator<Map.Entry<Term, Float>> it = tools.entrySet().iterator();
      while (it.hasNext()) {
        Map.Entry<Term, Float> entry = it.next();
        if (lastToolTerm!=null) if (entry.getKey().txt.equals(lastToolTerm.txt)) it.remove();
      }
      Term tool = pickWeightedRandomTerm(tools);
      lastToolTerm = tool;
      sentence += " "+tool.txt;
      // color
      HashMap<String, Float> colorsAdj = new HashMap<String, Float>();
      // colorsAdj.put("<span style=\"color: red;\">rouge</span>"+(tool.number>1?"s":""), 1.0);
      // colorsAdj.put("<span style=\"color: green;\">vert</span>"+(tool.gender==1?"e":"")+(tool.number>1?"s":""), 1.0);
      // colorsAdj.put("<span style=\"color: blue;\">bleu</span>"+(tool.gender==1?"e":"")+(tool.number>1?"s":""), 1.0);
      // colorsAdj.put("<span style=\"color: jaune;\">jaune</span>"+(tool.number>1?"s":""), 1.0);
      // colorsAdj.put("<span style=\"color: pink;\">violet</span>"+(tool.gender==1?"te":"")+(tool.number>1?"s":""), 0.7);
      // colorsAdj.put("<span style=\"color: orange;\">orange</span>"+(tool.number>1?"s":""), 0.7);
      // colorsAdj.put("<span style=\"color: gray;\">gris</span>"+(tool.gender==1?"e"+(tool.number>1?"s":""):""), 0.7);
      // colorsAdj.put("<span style=\"color: gray;\">blanc</span>"+(tool.gender==1?"he":"")+(tool.number>1?"s":""), 0.3);
      colorsAdj.put("<span style=\"color: black;\">noir</span>"+(tool.gender==1?"e":"")+(tool.number>1?"s":""), 3.0);
      // colorsAdj.put("<span style=\"color: black;\">multicolore</span>"+(tool.number>1?"s":""), 0.5);
      sentence += " "+pickWeightedRandom(colorsAdj);
    }
    if (actionType.equals(indent+"Dessinez")) {
      // nombre
      number = 1;
      number = floor(pow(random(1), 20)*20+1);
      // formes
      HashMap<Term, Float> shapes = new HashMap<Term, Float>();
      shapes.put(new Term("point"+(number>1?"s":""), 2, number), 3.0);
      shapes.put(new Term("carré"+(number>1?"s":""), 2, number), 2.0);
      shapes.put(new Term("rectangle"+(number>1?"s":""), 2, number), 2.0);
      shapes.put(new Term("losange"+(number>1?"s":""), 2, number), 2.0);
      shapes.put(new Term("arc"+(number>1?"s":"")+" de cercle", 2, number), 2.0);
      shapes.put(new Term("rond"+(number>1?"s":""), 2, number), 2.0);
      shapes.put(new Term("triangle"+(number>1?"s":""), 2, number), 2.0);
      shapes.put(new Term("polygone"+(number>1?"s":"")+" à "+floor(random(7)+3)+" côtés", 2, number), 2.0);
      shapes.put(new Term("trait"+(number>1?"s":""), 2, number), 2.0);
      shapes.put(new Term("courbe"+(number>1?"s":""), 1, number), 2.0);
      shapes.put(new Term("gribouillis", 2, number), 2.0);
      shapes.put(new Term("spirale"+(number>1?"s":""), 1, number), 2.0);
      shapes.put(new Term("forme"+(number>1?"s":"")+" patatoïdale"+(number>1?"s":""), 1, number), 2.0);
      shapes.put(new Term("arborescence"+(number>1?"s":""), 1, number), 2.0);
      shapes.put(new Term("éclaté"+(number>1?"s":""), 2, number), 0.5);
      shapes.put(new Term("astérisque"+(number>1?"s":""), 2, number), 0.5);
      shapes.put(new Term("angle"+(number>1?"s":""), 2, number), 0.5);
      shapes.put(new Term("mot"+(number>1?"s":"")+" de votre choix", 2, number), 1.0);
      shapes.put(new Term("chiffre"+(number>1?"s":""), 2, number), 1.0);
      shapes.put(new Term("ellipse"+(number>1?"s":""), 1, number), 0.5);
      shapes.put(new Term("zigzag"+(number>1?"s":""), 2, number), 0.5);
      shapes.put(new Term("visage"+(number>1?"s":""), 2, number), 0.15);
      shapes.put(new Term("pyramide"+(number>1?"s":""), 1, number), 0.1);
      shapes.put(new Term("cylindre"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("trou", 2, number), 0.1);
      shapes.put(new Term("parallélépipède"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("cube"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("pavé"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("étoile"+(number>1?"s":""), 1, number), 0.1);
      shapes.put(new Term("nuage"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("bâtiment"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("astre"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("véhicule"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("végéta"+(number>1?"ux":"l"), 2, number), 0.1);
      shapes.put(new Term((number>1?"yeux":"œil"), 2, number), 0.15);
      shapes.put(new Term("nez", 2, number), 0.15);
      shapes.put(new Term("bouche"+(number>1?"s":""), 1, number), 0.15);
      shapes.put(new Term("personnage"+(number>1?"s":""), 2, number), 0.15);
      shapes.put(new Term("anim"+(number>1?"aux":"al"), 2, number), 0.15);
      shapes.put(new Term("truc"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("bidule"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("machin"+(number>1?"s":""), 2, number), 0.1);
      shapes.put(new Term("fractale"+(number>1?"s":""), 1, number), 0.1);
      shapes.put(new Term("fenêtre"+(number>1?"s":""), 1, number), 0.1);
      shapes.put(new Term("forme"+(number>1?"s":""), 1, number), 0.1);
      shapes.put(new Term("forme"+(number>1?"s":"")+" symétrique", 1, number), 0.1);
      shapes.put(new Term("forme"+(number>1?"s":"")+" asymétrique", 1, number), 0.1);
      shapes.put(new Term("forme"+(number>1?"s":"")+" ondulante", 1, number), 0.1);
      shapes.put(new Term("objet"+(number>1?"s":""), 2, number), 0.1);
      Term shapeTerm = pickWeightedRandomTerm(shapes);
      sentence += " "+writtenNumber(number, shapeTerm.gender);
      gender = shapeTerm.gender;
      String shapeType = shapeTerm.txt;
      shapeName = shapeType;
      sentence += " "+underlined(shapeType)+"</span>";
      // attribut
      HashMap<String, Float> attributes = new HashMap<String, Float>();
      attributes.put("petit"+(gender==1?"e":"")+(number>1?"s":""), 2.0);
      attributes.put("<b>gros"+(gender==1?"se"+(number>1?"s":""):"")+"</b>", 2.0);
      attributes.put("de "+underlined(floor(random(10)+1)+" cm"), 10.0);
      attributes.put("en vous aidant d'une règle", 0.5);
      attributes.put("rapidement", 0.05);
      attributes.put("lentement", 0.05);
      attributes.put(writtenNumber(floor(random(3)+1), 1)+" fois", 1.0);
      attributes.put("de façon hésitante", 0.5);
      attributes.put("avec la main gauche", 0.5);
      attributes.put("avec la main droite", 0.5);
      attributes.put("en fermant les yeux", 0.5);
      attributes.put("en mangeant des carotte rapées", 0.01);
      attributes.put("tout"+(gender==1?"e":"")+(number>1?"s":"")+" simple"+(number>1?"s":""), 1.0);
      attributes.put("majestueu"+(gender==1?"se":"x"), 1.0);
      attributes.put("rigolo"+(gender==1?"tte":""), 1.0);
      attributes.put("spectaculaire"+(number>1?"s":""), 1.0);
      attributes.put("sobre"+(number>1?"s":""), 1.0);
      attributes.put("froid"+(number>1?"s":""), 1.0);
      attributes.put("chaleureu"+(gender>1?"se":"x")+((number>1&&gender==0)?"s":""), 1.0);
      attributes.put("déformé"+(gender>1?"e":"")+(number>1?"s":""), 1.0);
      attributes.put("en mouvement", 1.0);
      attributes.put("éclatant"+(gender==1?"e":"")+(number>1?"s":""), 0.5);
      attributes.put("vibrant"+(gender==1?"e":"")+(number>1?"s":""), 0.5);
      attributes.put("à motifs", 1.0);
      attributes.put("comme vous le sentez", 0.5);
      sentence += " "+pickWeightedRandom(attributes);
      // position
      HashMap<String, Float> locations = new HashMap<String, Float>();
      if (numberOfActualShapes()>0) {
        locations.put("au centre "+pickExistingShape("du"), 1.0);
        locations.put("à l'intérieur "+pickExistingShape("du"), 1.0);
        locations.put("à l'extérieur "+pickExistingShape("du"), 1.0);
        locations.put("au dessus "+pickExistingShape("du"), 2.0);
        locations.put("au dessous "+pickExistingShape("du"), 2.0);
        locations.put("à droite "+pickExistingShape("du"), 2.0);
        locations.put("à gauche "+pickExistingShape("du"), 2.0);
        locations.put("séparé"+(gender==1?"e":"")+(number>1?"s":"")+" "+pickExistingShape("du"), 1.0);
        locations.put("qui touche "+pickExistingShape("le"), 4.0);
        locations.put("par dessus "+pickExistingShape("le"), 1.0);
      }
      if (numberOfActualShapes()>1) {
        locations.put("qui relie "+pickExistingShape("le")+" "+pickExistingShape("au"), 1.0);
        locations.put("qui entoure "+pickExistingShape("le")+" et "+pickExistingShape("le"), 0.5);
        locations.put("entre "+pickExistingShape("le")+" et "+pickExistingShape("le"), 2.0);
      }
      locations.put("au milieu de la feuille", 1.0);
      locations.put("en haut de la feuille", 0.5);
      locations.put("à droite de la feuille", 0.5);
      locations.put("à gauche de la feuille", 0.5);
      locations.put("sur les bords", 0.5);
      locations.put("légèrement hors champ", 1.0);
      String locationType =  pickWeightedRandom(locations);
      sentence += " "+locationType;
    }
    sentence += ".";
    println(sentence);
  }
  String getShape() {
    return shapeName;
  }
}

<T> String underlined(T t) {
  return underlined(t.toString());
}

String underlined(String s) {
  return "<span style=\"text-decoration: underline;\">"+s+"</span>";
}

String pickWeightedRandom(HashMap<String, Float> options) {
  float total = 0;
  for (Map.Entry<String, Float> entry : options.entrySet()) total += entry.getValue();
  float choiceIndex = random(total);
  for (Map.Entry<String, Float> entry : options.entrySet()) {
    choiceIndex -= entry.getValue();
    if (choiceIndex <= 0) {
      return entry.getKey();
    }
  }
  return "";
}

Term pickWeightedRandomTerm(HashMap<Term, Float> options) {
  float total = 0;
  for (Map.Entry<Term, Float> entry : options.entrySet()) total += entry.getValue();
  float choiceIndex = random(total);
  for (Map.Entry<Term, Float> entry : options.entrySet()) {
    choiceIndex -= entry.getValue();
    if (choiceIndex <= 0) {
      return entry.getKey();
    }
  }
  return null;
}

String pickExistingShape(String article) {
  int offset = floor(random(instructions.size()));
  for (int i=0; i<instructions.size(); i++) {
    Instruction thisInstruction = instructions.get((offset+i)%instructions.size());
    if (thisInstruction.getShape()!=null) {
      if (article.equals("")) return thisInstruction.getShape();
      if (article.equals("le")) {
        String txt = "";
        if (thisInstruction.number>1) {
          txt += "les";
          if (thisInstruction.number<6) txt += " "+writtenNumber(thisInstruction.number, 0);
        } else {
          char firstChar = thisInstruction.shapeName.charAt(0);
          if (firstChar=='a'||firstChar=='e'||firstChar=='i'||firstChar=='o'||firstChar=='u'||firstChar=='y') {
            txt += "l'";
          } else {
            if (thisInstruction.gender==1) txt += "la";
            if (thisInstruction.gender==2) txt += "le";
          }
        }
        if (txt.charAt(txt.length()-1)!='\'') txt += " ";
        txt += "<span style=\"text-decoration:underline;\">"+thisInstruction.getShape()+"</span>";
        return txt;
      }
      if (article.equals("du")) {
        String txt = "";
        if (thisInstruction.number>1) {
          txt += "des";
          if (thisInstruction.number<6) txt += " "+writtenNumber(thisInstruction.number, 0);
        } else {
          char firstChar = thisInstruction.shapeName.charAt(0);
          if (firstChar=='a'||firstChar=='e'||firstChar=='i'||firstChar=='o'||firstChar=='u'||firstChar=='y') {
            txt += "de l'";
          } else {
            if (thisInstruction.gender==1) txt += "de la";
            if (thisInstruction.gender==2) txt += "du";
          }
        }
        if (txt.charAt(txt.length()-1)!='\'') txt += " ";
        txt += "<span style=\"text-decoration:underline;\">"+thisInstruction.getShape()+"</span>";
        return txt;
      }
      if (article.equals("au")) {
        String txt = "";
        if (thisInstruction.number>1) {
          txt += "aux";
          if (thisInstruction.number<6) txt += " "+writtenNumber(thisInstruction.number, 0);
        } else {
          char firstChar = thisInstruction.shapeName.charAt(0);
          if (firstChar=='a'||firstChar=='e'||firstChar=='i'||firstChar=='o'||firstChar=='u'||firstChar=='y') {
            txt += "à l'";
          } else {
            if (thisInstruction.gender==1) txt += "à la";
            if (thisInstruction.gender==2) txt += "au";
          }
        }
        if (txt.charAt(txt.length()-1)!='\'') txt += " ";
        txt += "<span style=\"text-decoration:underline;\">"+thisInstruction.getShape()+"</span>";
        return txt;
      }
    }
  }
  if (article.equals("le")) return "rien de spécial";
  if (article.equals("du")) return "de rien de spécial";
  if (article.equals("au")) return "à rien de spécial";
  return "rien de spécial";
}

String writtenNumber(int number, int gender) {
  if (number==0) return "zéro";
  if (number==1) return (gender==1)?"une":"un";
  if (number==2) return "deux";
  if (number==3) return "trois";
  if (number==4) return "quatre";
  if (number==5) return "cinq";
  if (number==6) return "six";
  if (number==7) return "sept";
  if (number==8) return "huit";
  if (number==9) return "neuf";
  if (number==10) return "dix";
  if (number==11) return "onze";
  if (number==12) return "douze";
  if (number==13) return "treize";
  if (number==14) return "quatorze";
  if (number==15) return "quinze";
  if (number>15) return "plusieurs";
  return str(number);
}

class Term {
  String txt = "";
  int gender = -1;
  int number = -1;
  Term (String txt, int gender, int number) {
    this.txt = txt;
    this.gender = gender;
    this.number = number;
  }
}

String stripHtml(String input) {
  // Replace &nbsp; with spaces
  input = input.replaceAll("&nbsp;", " ");
  
  String output = ""+input;
  boolean inside = false;
  for (int i=output.length()-1; i>=0; i--) {
    if (output.charAt(i)=='>') inside = true;
    boolean soonOut = (output.charAt(i)=='<');
    if (inside) output = output.substring(0, i)+output.substring(i+1, output.length());
    if (soonOut) inside = false;
  }
  return output;
}

int numberOfActualShapes() {
  int i=0;
  for (Instruction ins : instructions) if (ins.shapeName!=null) i++;
  return i;
}
