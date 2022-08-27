'''Создание класса, описывающего склад. А также класса «Оргтехника», который будет базовым для классов-наследников.
Эти классы — конкретные типы оргтехники (принтер, сканер, ксерокс). В базовом классе определить параметры, общие для приведённых типов.
В классах-наследниках реализовать параметры, уникальные для каждого типа оргтехники.

Разработать методы, которые отвечают за приём оргтехники на склад и передачу в определённое подразделение компании.
Для хранения данных о наименовании и количестве единиц оргтехники, а также других данных, используем любую подходящую структуру (например, словарь).

Реализуйте механизм валидации вводимых пользователем данных.'''

class Warehouse:

    def __init__(self):
        self.id_base = [] # cписок номенклатуры
        self.obj_base = [] # список обьектов

    def validate_result(func): # функция-ДЕКОРАТОР строится именно так
        # Если при вызове  функции func в программе произойдет ошибка,
        # то эта функция-декоратор перехватит ее и напишет сообщение
        def inner_func(*args):
            try:
                func(*args)
            except Exception:
                print('неверные входные данные')
        return inner_func

    def add_id_base(self, *args): # функция добавляения позиуии в номенклатуру
        self.id_base.append({args[0]: [*args[1:]]})

    def get_var_names(self):    # функция получения имени экземпляра класса (ЧЕСТНО ЕЕ ЗАГУГЛИЛ)
        return [k for k, v in globals().items() if v is self]

    def __str__(self): # строковое представление имени подразделения, используя функцию выше
        return f'{self.get_var_names()}'

    def get_show(self, list1): # функция отображения количества товаров в данном подразделении
        print(f'Список объектов подразделения {self}: ')

        dict_count = {} # словарь для отображения

        for el in list1: # пробегаемся по элементам входного списка

            if str(el) not in dict_count:
                ''' если строковое отображение элемента(объекта) нет в словаре, добавляем его,
                в значении пишем список который отображает количество штук, в данном случае 1 '''
                dict_count[str(el)] = [1, 'шт.']
            else: # в противном случае, количество штук увеличиваем на 1
                dict_count[str(el)][0] += 1

        for el, zn in dict_count.items(): # пробегаемся по итоговому словарю и выводим, построчно пару ключ-значение
            print(el, *zn)

        print()

    @validate_result
    def copy_id_base(self, name_subdivision): # функция копирования справочника для нового подразделения
        self.id_base = name_subdivision.id_base[:]

    @validate_result # навешиваем валидацию на функцию добавления объекта
    def add_obj_base(self, art, num): # наша функция, которая добавляет объект/объекты в список по артикулу и количеству

        flag = False # флаг для вывода сообщения 'нет такой позиции'
        for j in range(num): # цикл по количеству товара
            for i, el in enumerate(self.id_base): # цикл по каждому словарю из справочника номенклатуры
                if art in el.keys(): # если введеный артикул равен ключу проверяемого словаря, то создаем объект
                    #  создаем объект по данным из номенклатуры
                    obj = wh.id_base[i][art][0](wh.id_base[i][art][3], wh.id_base[i][art][1], wh.id_base[i][art][2], i)
                    self.obj_base.append(obj) # добавляем к общему списку объектов
                    flag = True # меняем флаг на True чтобы не отпринтовывать сообщение ниже
        if not flag:
            print(f'{art} - нет такой позици в номенклатуре')

    @validate_result # также навешиваем валидацию на функцию удаления объекта
    def sub_obj_base(self, art, num, subdivision):
        if isinstance(subdivision, Warehouse):
            n = 0
            for i, el in enumerate(self.obj_base):
                if art == el.art:
                    n += 1

            if n >= num:
                for j in range(num):
                    for i, el in enumerate(self.obj_base):
                        if art == el.art:
                            subdivision.add_obj_base(art, 1) # перелаем данный товар в базу объектов указанного подразделения
                            self.obj_base.remove(el) # списываем со склада подразделения данный объект
                print(f'Товара арт.[{art}] отправлен в {subdivision} в размере {num} шт. Осталось {n-num} шт.\n')

            elif n:
                print(f'Товара арт.[{art}] не хватает для отправки в размере {num} шт. На складе есть {n} шт.\n')

            else:
                print('Такого товара  нет в наличии\n')
        else:
            print('Нет такого подразделения\n')

class OfficeEquipment:

    def __init__(self, name, cost, art):
        self.name = name
        self.cost = cost
        self.art = art


class Xerox(OfficeEquipment): # Класс ксероксов

    def __init__(self, type, *args):
        OfficeEquipment.__init__(self, *args)
        self.type = type

    def __str__(self):
        return f'Aрт.[{self.art}] Xerox - Фирма: {self.name}. Цена: {self.cost}. Тип печати: {self.type}.'


class Printer(OfficeEquipment): # Класс принтеров

    def __init__(self, speed_print, *args):
        OfficeEquipment.__init__(self, *args)
        self.speed_print = speed_print

    def __str__(self):
        return f'Aрт.[{self.art}] Printer - Фирма: {self.name}. Цена: {self.cost}. Скорость печати: {self.speed_print}.'

class Scaner(OfficeEquipment): # Класс сканеров

    def __init__(self, formatA, *args):
        OfficeEquipment.__init__(self, *args)
        self.formatA = formatA

    def __str__(self):
        return f'Aрт.[{self.art}] Scaner - Фирма: {self.name}. Цена: {self.cost}. Формат: {self.formatA}.'

wh = Warehouse() # строим наш склад с название wh
'''Как в любой нормальной базе данных предприятия, сначала заводятся позиции в базе с персональным кодом(артикулом),
со всем описанием, свойствами, картинками если надо.
А уже затем, по этой позиции принимается/отправляется количество товара в подразделении'''

wh.add_id_base(0, Xerox, 'Samsung', 5000, 'laser')
wh.add_id_base(1, Xerox, 'HP', 4000, 'jet')
wh.add_id_base(2, Printer, 'HP', 4500, 50)
wh.add_id_base(3, Scaner, 'Epson', 3000, 'A4')
wh.add_id_base(4, Scaner, 'Canon', 7500, 'A3')

sm = Warehouse() # строим наш магазин
sm.copy_id_base(wh) # копираем справочник номенклатуры склада, чтобы не вводить 2 раза

# Наполняем склад товарами из справочника номенклатуры указывая артикул и количество
wh.add_obj_base(1, 2)
wh.add_obj_base(3, 2)

# выводим список товаров с количеством
wh.get_show(wh.obj_base)

# отправляем объекты со склада в магазин
wh.sub_obj_base(1, 1, sm)

# выводим список товаров в с количеством в обоих подразделениях
wh.get_show(wh.obj_base)
sm.get_show(sm.obj_base)

# отправляем обратно с магазина на склад
sm.sub_obj_base(1, 1, wh)

# выводим список товаров в с количеством в обоих подразделениях
wh.get_show(wh.obj_base)
sm.get_show(sm.obj_base)

''' Теперь можно создавать сколько угодно подразделений, сколько угодно позиций товара в базе,
и сколько угодно объектов в каждом подразделении используя созданные методы, и также бесконечно передавать товары
между подразделениями, и выводя текущий остаток товаров в каждом '''

