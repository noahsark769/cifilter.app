import React from 'react';
import styled from 'styled-components';

import Image from './Image';

const FilterExample = (props) => {
    console.log(props);
    return (
        <Image
            filename={`${props.example.basepath}/${props.example.data._metadata._associations.inputImage.image}`}
        />
    )
};
export default FilterExample;