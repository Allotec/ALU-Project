#Syntax For all Instructions
#OR -> OR rd, rx, ry
#XOR -> XOR rd, rx, ry
#AND -> AND rd, rx, ry
#NOT -> NOT rd, rx
#Left Shift Logical -> LSHIFT rd, rx
#Right Shift Logical -> RSHIFT rd, rx
#Right Shift Arithmetic -> ARSHIFT rd, rx
#ADD -> ADD rd, rx, ry
#ADDC -> ADDC rd, rx, ry
#SUB -> SUB rd, rx, ry
#Load Lower -> LOADLO rd, imm
#Load High -> LOADHI rd, imm
#OUT -> out rx
#HALY -> halt rx

input = open("test.txt", "r")
output = open("assemblyProgram.txt", "w")

#Data structures to hold the hex number to name conversions
opCodeThreeOperand = {
    "0" : "OR",
    "1" : "XOR",
    "2" : "AND",
    "7" : "ADD",
    "8" : "ADDC",
    "9" : "SUB"
}

opCodeTwoOperand = {
    "3" : "NOT",
    "4" : "LSHIFT",
    "5" : "RSHIFT",
    "6" : "ARSHIFT",
    "A" : "LOADLO",
    "B" : "LOADHI"
}

opCodeOneOperand = {
    "C" : "OUT",
    "D" : "HALT"
}

lines = input.readlines()
splitInstruction = []
bits = 12

#Loops over all the lines in the program file
for i in range(len(lines)):
    splitInstruction.insert(i, lines[i].strip())

    #Logic for instructions with three operands
    if splitInstruction[i][0] in opCodeThreeOperand:
        output.write(opCodeThreeOperand[splitInstruction[i][0]])
        splitInstruction[i] = bin(int(splitInstruction[i], 16))[2:].zfill(bits)
        output.write(" " + str(int(splitInstruction[i][4:6], 2)) + ", " + str(int(splitInstruction[i][6:8], 2)) + ", " + str(int(splitInstruction[i][8:10], 2)) + "\n")

    #Logic for instructions with two operands
    elif splitInstruction[i][0] in opCodeTwoOperand:
        output.write(opCodeTwoOperand[splitInstruction[i][0]])
        
        #Logic for immediate instructions
        if splitInstruction[i][0] == 'A' or splitInstruction[i][0] == 'B':
            splitInstruction[i] = bin(int(splitInstruction[i], 16))[2:].zfill(bits)
            output.write(" " + str(int(splitInstruction[i][4:6], 2)) + ", " + str(int(splitInstruction[i][6:12], 2)) + "\n")

        #Logic for non-immediate instructions
        else:            
            splitInstruction[i] = bin(int(splitInstruction[i], 16))[2:].zfill(bits)
            output.write(" " + str(int(splitInstruction[i][4:6], 2)) + ", " + str(int(splitInstruction[i][6:8], 2)) + "\n")

    #Logic for instructions with one operand
    elif splitInstruction[i][0] in opCodeOneOperand:
        output.write(opCodeOneOperand[splitInstruction[i][0]])
        splitInstruction[i] = bin(int(splitInstruction[i], 16))[2:].zfill(bits)
        output.write(" " + str(int(splitInstruction[i][6:8], 2)) + '\n')


input.close()
output.close()
